//
//  AppView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/17/23.
//

import SwiftUI

struct AppView: View {
    @Binding var selectedImageId: SDImage.ID?
    @Binding var galleryConfig: GalleryConfig
    @EnvironmentObject private var imageStore: ImageStore
    @EnvironmentObject private var promptStore: PromptStore

    var body: some View {
        NavigationSplitView {
            SidebarView(generate: generate)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            HStack(alignment: .center, spacing: 0) {
                GalleryView(selection: $selectedImageId, copyToPrompt: copyToPrompt)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                if let index = selectedImageId, let sdi = imageStore.image(with: index) {
                    InspectorView(
                        sdi: sdi,
                        copyToPrompt: <#T##(SDImage) -> Void#>
                    )
                    .frame(maxWidth: 340)
                } else {
                    EmptyInspectorView()
                        .frame(maxWidth: 340)
                }
            }
        }
        .searchable(text: $galleryConfig.searchText, prompt: "Search")
    }

    func generate() {
        promptStore.generate(imageStore: imageStore)
    }

    func copyToPrompt(_ sdi: SDImage) {

    }
}
