//
//  SaveCommands.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/16/22.
//

import SwiftUI

struct FileCommands: Commands {
    @Binding var selectedImageId: SDImage.ID?
    @ObservedObject var imageStore: ImageStore

    var body: some Commands {
        CommandGroup(replacing: .saveItem) {
            Section {
                Button {
                    guard let id = selectedImageId, let sdi = imageStore.image(with: id) else { return }
                    sdi.save()
                } label: {
                    Text(
                        "Save As...",
                        comment: "Show the save image dialog"
                    )
                }
                .keyboardShortcut("S", modifiers: .command)
                .disabled(selectedImageId == nil)

                Button {
                    imageStore.saveAllImages()
                } label: {
                    Text(
                        "Save All...",
                        comment: "Show the save images dialog"
                    )
                }
                .keyboardShortcut("S", modifiers: [.command, .option])
                .disabled(imageStore.images.isEmpty)
            }
        }
    }
}
