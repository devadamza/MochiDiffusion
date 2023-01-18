//
//  SidebarView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/17/23.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var promptStore: PromptStore
    var generate: () -> Void

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 6) {
                Group {
                    PromptView(
                        prompt: $promptStore.prompt,
                        negativePrompt: $promptStore.negativePrompt,
                        upscaleGeneratedImages: $promptStore.upscaleGeneratedImages,
                        isGenerateDisabled: promptStore.currentModel.isEmpty,
                        status: promptStore.status,
                        generate: generate,
                        stopGeneration: Generator.shared.stopGeneration
                    )
                    Divider().frame(height: 16)
                }
                Group {
                    NumberOfImagesView(numberOfImages: $promptStore.numberOfImages)
                    Spacer()
                }
                Group {
                    StepsView(steps: $promptStore.steps)
                    Spacer()
                }
                Group {
                    GuidanceScaleView(guidanceScale: $promptStore.guidanceScale)
                    Spacer()
                }
                Group {
                    SeedView(seed: $promptStore.seed)
                    Spacer()
                }
                Group {
                    ModelView(
                        models: $promptStore.models,
                        currentModel: $promptStore.currentModel,
                        loadModels: promptStore.loadModels
                    )
                }
            }
            .padding([.horizontal, .bottom])
        }
    }
}
