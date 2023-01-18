//
//  InspectorView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/19/22.
//
// swiftlint:disable line_length

import StableDiffusion
import SwiftUI

// TODO: move out
enum PromptOption {
    case prompt(String)
    case negativePrompt(String)
    case scheduler(StableDiffusionScheduler)
    case seed(UInt32)
    case steps(Int)
    case guidanceScale(Double)
    case all(SDImage)
}

struct InfoGridRow: View {
    var type: LocalizedStringKey
    var text: String
    var showCopyToPromptOption: Bool
    var callback: ((PromptOption) -> Void)?

    var body: some View {
        GridRow {
            Text("")
            Text(type)
                .helpTextFormat()
        }
        GridRow {
            if showCopyToPromptOption {
//                Button {
//                    guard let callbackFn = callback else { return }
//                    callbackFn()
//                } label: {
//                    Image(systemName: "arrow.left.circle.fill")
//                        .foregroundColor(Color.secondary)
//                }
//                .buttonStyle(PlainButtonStyle())
//                .help("Copy Option to Sidebar")
                Text("")
            } else {
                Text("")
            }

            Text(text)
                .selectableTextFormat()
        }
        Spacer().frame(height: 12)
    }
}

struct InspectorView: View {
//    @Binding var config: InspectorConfig
    var sdi: SDImage
    var copyToPrompt: (PromptOption) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if let img = sdi.image {
                Image(img, scale: 1, label: Text(verbatim: String(sdi.prompt)))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(4)
                    .shadow(color: sdi.image?.averageColor ?? .black, radius: 12)
                    .padding()

                ScrollView(.vertical) {
                    Grid(alignment: .leading, horizontalSpacing: 4) {
                        InfoGridRow(
                            type: "Date",
                            text: sdi.generatedDate.formatted(date: .long, time: .standard),
                            showCopyToPromptOption: false
                        )
                        InfoGridRow(
                            type: "Model",
                            text: sdi.model,
                            showCopyToPromptOption: false
                        )
                        InfoGridRow(
                            type: "Size",
                            text: "\(sdi.width) x \(sdi.height)\(sdi.isUpscaled ? " (Converted to High Resolution)" : "")",
                            showCopyToPromptOption: false
                        )
                        InfoGridRow(
                            type: "Include in Image",
                            text: sdi.prompt,
                            showCopyToPromptOption: true,
//                            callback: copyToPrompt(.prompt(sdi.prompt))
                        )
                        InfoGridRow(
                            type: "Exclude from Image",
                            text: sdi.negativePrompt,
                            showCopyToPromptOption: true,
//                            callback: copyToPrompt(.negativePrompt(sdi.negativePrompt))
                        )
                        InfoGridRow(
                            type: "Scheduler",
                            text: sdi.scheduler.rawValue,
                            showCopyToPromptOption: true,
//                            callback: copyToPrompt(.scheduler(sdi.scheduler))
                        )
                        InfoGridRow(
                            type: "Seed",
                            text: String(sdi.seed),
                            showCopyToPromptOption: true,
//                            callback: copyToPrompt(.seed(sdi.seed))
                        )
                        InfoGridRow(
                            type: "Steps",
                            text: String(sdi.steps),
                            showCopyToPromptOption: true,
//                            callback: copyToPrompt(.steps(sdi.steps))
                        )
                        InfoGridRow(
                            type: "Guidance Scale",
                            text: String(sdi.guidanceScale),
                            showCopyToPromptOption: true,
//                            callback: copyToPrompt(.guidanceScale(sdi.guidanceScale))
                        )
                    }
                }
                .padding([.horizontal])

                HStack(alignment: .center) {
                    Button {
                        copyToPrompt(.all(sdi))
                    } label: {
                        Text(
                            "Copy Options to Sidebar",
                            comment: "Button to copy the currently selected image's generation options to the prompt input sidebar"
                        )
                    }
                    Button {
                        let info = getHumanReadableInfo(sdi: sdi)
                        let pasteboard = NSPasteboard.general
                        pasteboard.declareTypes([.string], owner: nil)
                        pasteboard.setString(info, forType: .string)
                    } label: {
                        Text(
                            "Copy",
                            comment: "Button to copy the currently selected image's generation options to the clipboard"
                        )
                    }
                }
                .padding()
            }
        }
    }
}
