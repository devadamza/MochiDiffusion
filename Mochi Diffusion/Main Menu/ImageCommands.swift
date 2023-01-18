//
//  ImageCommands.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/14/23.
//

import SwiftUI

struct ImageCommands: Commands {
    @ObservedObject var promptStore: PromptStore
    @Binding var selectedImageId: SDImage.ID?
    @Binding var isImagesEmpty: Bool
    @Binding var galleryConfig: GalleryConfig

    var body: some Commands {
        CommandMenu("Image") {
            Section {
                if case .running = promptStore.status {
                    Button {
                        Generator.shared.stopGeneration()
                    } label: {
                        Text("Stop Generation")
                    }
                    .keyboardShortcut("G", modifiers: .command)
                } else {
                    Button {
                        promptStore.generate(imageStore: imageStore)
                    } label: {
                        Text("Generate")
                    }
                    .keyboardShortcut("G", modifiers: .command)
                    .disabled(promptStore.currentModel.isEmpty)
                }
            }
            Section {
                Button {
                    guard let id = selectedImageId else { return }
                    selectedImageId = galleryConfig.selectNextImage(
                        id: id,
                        imageStore: imageStore
                    )
                } label: {
                    Text(
                        "Select Next",
                        comment: "Select next image in Gallery"
                    )
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .disabled(imageStore.images.isEmpty)

                Button {
                    guard let id = selectedImageId else { return }
                    selectedImageId = galleryConfig.selectPreviousImage(
                        id: id,
                        imageStore: imageStore
                    )
                } label: {
                    Text(
                        "Select Previous",
                        comment: "Select previous image in Gallery"
                    )
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .disabled(imageStore.images.isEmpty)
            }
            Section {
                Button {
                    guard let id = selectedImageId else { return }
                    guard let sdi = imageStore.image(with: id) else { return }
                    guard let upscaledImage = Upscaler.shared.upscaleImage(sdi: sdi) else { return }
                    selectedImageId = imageStore.add(upscaledImage)
                } label: {
                    Text(
                        "Convert to High Resolution",
                        comment: "Convert the current image to high resolution"
                    )
                }
                .keyboardShortcut("R", modifiers: .command)
                .disabled(selectedImageId == nil)

                Button {
                    guard let id = selectedImageId else { return }
                    guard let sdi = imageStore.image(with: id) else { return }
                    galleryConfig.quicklookImage(sdi)
                } label: {
                    Text(
                        "Quick Look",
                        comment: "View current image using Quick Look"
                    )
                }
                .keyboardShortcut("L", modifiers: .command)
                .disabled(selectedImageId == nil)
            }
            Section {
                Button {
                    guard let id = selectedImageId else { return }
                    imageStore.remove(id)
                } label: {
                    Text(
                        "Remove",
                        comment: "Remove image from the gallery"
                    )
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(selectedImageId == nil)
            }
        }
    }
}
