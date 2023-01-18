//
//  PromptStore.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/17/23.
//

import CoreML
import Foundation
import StableDiffusion
import SwiftUI

final class PromptStore: ObservableObject {
    @Published var numberOfImages = 1
    @Published var models = [Model]()
    @Published var status: GeneratorStatus = Generator.shared.status
    @Published var queueProgress: QueueProgress = Generator.shared.queueProgress
    @Published var seed: UInt32 = 0
    @AppStorage("ModelDir") var modelDir = ""
    @AppStorage("Prompt") var prompt = ""
    @AppStorage("NegativePrompt") var negativePrompt = ""
    @AppStorage("Steps") var steps = 28
    @AppStorage("Scale") var guidanceScale = 11.0
    @AppStorage("Scheduler") var scheduler = StableDiffusionScheduler.dpmSolverMultistepScheduler
    @AppStorage("UpscaleGeneratedImages") var upscaleGeneratedImages = false
#if arch(arm64)
    @AppStorage("MLComputeUnit") var mlComputeUnit: MLComputeUnits = .cpuAndNeuralEngine
#else
    var mlComputeUnit: MLComputeUnits = .cpuAndGPU
#endif
    @AppStorage("ReduceMemory") var reduceMemory = false
    @AppStorage("Model") private var model = ""
    var currentModel: Model {
        get {
            model
        }
        set {
            model = newValue
            Task {
                await Generator.shared.loadModel(
                    modelDir: modelDir,
                    modelName: newValue,
                    computeUnit: mlComputeUnit,
                    reduceMemory: reduceMemory
                )
            }
        }
    }

    func copyToPrompt(sdi: SDImage) {
        prompt = sdi.prompt
        negativePrompt = sdi.negativePrompt
        steps = sdi.steps
        guidanceScale = sdi.guidanceScale
        seed = sdi.seed
        scheduler = sdi.scheduler
    }

    func loadModels() {
        Generator.shared.loadModels(modelDir)
    }

    func loadModel() async {
        await Generator.shared.loadModel(
            modelDir: modelDir,
            modelName: model,
            computeUnit: mlComputeUnit,
            reduceMemory: reduceMemory
        )
    }

    func generate(imageStore: ImageStore) {
        Generator.shared.generate(
            prompt: prompt,
            negativePrompt: negativePrompt,
            stepCount: steps,
            seed: seed,
            guidanceScale: guidanceScale,
            numberOfImages: numberOfImages,
            scheduler: scheduler,
            upscaleGeneratedImages: upscaleGeneratedImages,
            imageStore: imageStore
        )
    }
}
