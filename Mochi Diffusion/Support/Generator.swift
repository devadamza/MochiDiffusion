//
//  Generator.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/17/23.
//

import Combine
import CoreML
import Foundation
import os
import StableDiffusion
import SwiftUI

typealias Model = String
typealias StableDiffusionProgress = StableDiffusionPipeline.Progress

enum GeneratorStatus {
    case initialized
    case loadedModels([Model])
    case loadedModel(Model)
    case ready
    case loading
    case running(StableDiffusionProgress?)
    case error(String)
}

final class Generator {
    static let shared = Generator()
    var status = GeneratorStatus.initialized
    var queueProgress = QueueProgress()
    var model: Model = ""
    var pipeline: StableDiffusionPipeline?
    var progress: StableDiffusionProgress? {
        didSet {
            progressPublisher.value = progress
        }
    }
    var hasGenerationBeenStopped: Bool {
        generationStopped
    }
    private var progressSubscriber: Cancellable?
    private var generationStopped = false
    private(set) lazy var progressPublisher: CurrentValueSubject<
        StableDiffusionProgress?, Never
    > = CurrentValueSubject(progress)
    private let logger = Logger()

    private init() {
        logger.info("Generator init")
    }

    func loadModels(_ modelDir: String) {
        logger.info("Started loading model directory at: \"\(modelDir)\"")
        let fm = FileManager.default
        var finalModelDir: URL
        // check if saved model directory exists
        if modelDir.isEmpty {
            // use default model directory
            guard let documentsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
                status = .error("Couldn't access model directory.")
                return
            }
            finalModelDir = documentsDir
            finalModelDir.append(path: "MochiDiffusion/models/", directoryHint: .isDirectory)
            if !fm.fileExists(atPath: finalModelDir.path(percentEncoded: false)) {
                logger.notice("Creating models directory at: \"\(finalModelDir.absoluteString)\"")
                try? fm.createDirectory(at: finalModelDir, withIntermediateDirectories: true)
            }
        } else {
            // generate url from saved model directory
            finalModelDir = URL(fileURLWithPath: modelDir, isDirectory: true)
        }

        var models: [Model] = []
        do {
            let dirContents = try fm.contentsOfDirectory(
                at: finalModelDir,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            dirContents.forEach { item in
                var isDir: ObjCBool = false
                fm.fileExists(atPath: item.path, isDirectory: &isDir)
                if isDir.boolValue {
                    models.append(item.lastPathComponent)
                }
            }
        } catch {
            logger.notice("Could not get subdirectories under: \"\(finalModelDir.absoluteString)\"")
            status = .error("Could not get subdirectories.")
            return
        }
        if models.isEmpty {
            logger.notice("No models found under: \"\(finalModelDir.absoluteString)\"")
            status = .error("No models found.")
            return
        }
        logger.info("Found \(models.count) model(s)")
        status = .loadedModels(models)
    }

    func loadModel(
        modelDir: String,
        modelName: String,
        computeUnit: MLComputeUnits,
        reduceMemory: Bool
    ) async {
        logger.info("Started loading model: \"\(modelName)\"")
        let dir = URL(fileURLWithPath: modelDir, isDirectory: true)
            .appending(component: modelName, directoryHint: .isDirectory)
        let fm = FileManager.default
        if !fm.fileExists(atPath: dir.path) {
            model = ""
            logger.info("Couldn't find model \"\(modelName)\" at: \"\(dir.absoluteString)\"")
            status = .error("Couldn't load \(modelName) because it doesn't exist.")
            return
        }
        logger.info("Found model: \"\(modelName)\"")
        let config = MLModelConfiguration()
        config.computeUnits = computeUnit
        do {
            let pipeline = try StableDiffusionPipeline(
                resourcesAt: dir,
                configuration: config,
                disableSafety: true,
                reduceMemory: reduceMemory
            )
            logger.info("Stable Diffusion pipeline successfully loaded")
            model = modelName
            self.pipeline = pipeline
            status = .ready
        } catch {
            model = ""
            status = .error("There was a problem loading the model: \(modelName)")
        }
    }

    // swiftlint:disable:next function_parameter_count function_body_length
    func generate(
        prompt: String,
        negativePrompt: String,
        stepCount: Int,
        seed: UInt32,
        guidanceScale: Double,
        numberOfImages: Int,
        scheduler: StableDiffusionScheduler,
        upscaleGeneratedImages: Bool,
        imageStore: ImageStore
    ) {
        if case GeneratorStatus.ready = status {
            // continue
        } else {
            return
        }
        guard let pipeline = pipeline else {
            status = .error("Pipeline is not loaded.")
            return
        }
        status = .loading
        progressSubscriber = progressPublisher.sink { progress in
            guard let progress = progress else { return }
            DispatchQueue.main.async {
                self.status = .running(progress)
            }
        }
        DispatchQueue.global(qos: .default).async {
            do {
                var seedUsed = seed == 0 ? UInt32.random(in: 0 ..< UInt32.max) : seed
                for index in 0 ..< numberOfImages {
                    DispatchQueue.main.async {
                        self.queueProgress = GenerationProgress(index: index, total: numberOfImages)
                    }
                    let beginDate = Date()
                    print("Generating...")
                    let results = try pipeline.generateImages(
                        prompt: prompt,
                        negativePrompt: negativePrompt,
                        imageCount: 1,
                        stepCount: stepCount,
                        seed: seed,
                        guidanceScale: Float(guidanceScale),
                        disableSafety: true,
                        scheduler: scheduler
                    ) { progress in
                        self.handleProgress(progress)
                    }
                    if self.hasGenerationBeenStopped {
                        break
                    }
                    print("Generation took \(Date().timeIntervalSince(beginDate))")
                    var images = [SDImage]()
                    var sdi = SDImage(
                        prompt: prompt,
                        negativePrompt: negativePrompt,
                        model: self.model,
                        scheduler: scheduler,
                        seed: seed,
                        steps: stepCount,
                        guidanceScale: guidanceScale
                    )
                    for image in results {
                        sdi.id = UUID()
                        sdi.image = image
                        sdi.width = image!.width
                        sdi.height = image!.height
                        sdi.aspectRatio = CGFloat(Double(image!.width) / Double(image!.height))
                        sdi.generatedDate = Date.now
                        images.append(sdi)
                    }
                    DispatchQueue.main.async {
                        if upscaleGeneratedImages {
                            self.upscaleThenAddImages(
                                simgs: images,
                                imageStore: imageStore
                            )
                        } else {
                            self.addImages(
                                simgs: images,
                                imageStore: imageStore
                            )
                        }
                    }
                    seedUsed += 1
                }
                self.progressSubscriber?.cancel()

                DispatchQueue.main.async {
                    self.status = .ready
                }
            } catch {
                self.logger.error("There was a problem generating images: \(error)")
                DispatchQueue.main.async {
                    self.status = .error("There was a problem generating images: \(error)")
                }
            }
        }
    }

    func stopGeneration() {
        generationStopped = true
    }

    private func handleProgress(_ progress: StableDiffusionPipeline.Progress) -> Bool {
        self.progress = progress
        return !generationStopped
    }

    @MainActor
    private func addImages(simgs: [SDImage], imageStore: ImageStore) {
        withAnimation(.default.speed(1.5)) {
            imageStore.add(simgs)
        }
    }

    @MainActor
    private func upscaleThenAddImages(simgs: [SDImage], imageStore: ImageStore) {
        var upscaledSDImgs = [SDImage]()
        for simg in simgs {
            guard let image = simg.image else { continue }
            guard let upscaledImage = Upscaler.shared.upscale(cgImage: image) else { continue }
            var sdi = simg
            sdi.image = upscaledImage
            sdi.width = upscaledImage.width
            sdi.height = upscaledImage.height
            sdi.aspectRatio = CGFloat(Double(sdi.width) / Double(sdi.height))
            sdi.isUpscaled = true
            upscaledSDImgs.append(sdi)
        }
        imageStore.add(upscaledSDImgs)
    }
}
