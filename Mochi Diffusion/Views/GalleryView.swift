//
//  GalleryView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/4/23.
//
// swiftlint:disable line_length

import QuickLook
import SwiftUI

struct GalleryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selection: SDImage.ID?
    var copyToPrompt: (SDImage) -> Void
    @EnvironmentObject private var imageStore: ImageStore
    @State private var galleryConfig = GalleryConfig()
    private let gridColumns = [GridItem(.adaptive(minimum: 200), spacing: 16)]

    var body: some View {
        VStack(spacing: 0) {
            if !imageStore.images.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(Array(searchResults.enumerated()), id: \.offset) { index, sdi in
                                GalleryItemView(sdi: sdi, index: index)
                                    .accessibilityAddTraits(.isButton)
                                    .onChange(of: selection) { target in
                                        withAnimation {
                                            proxy.scrollTo(target)
                                        }
                                    }
                                    .aspectRatio(sdi.aspectRatio, contentMode: .fit)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(
                                                sdi.id == selection ?
                                                Color.accentColor :
                                                    Color(nsColor: .controlBackgroundColor),
                                                lineWidth: 4
                                            )
                                    )
                                    .gesture(TapGesture(count: 2).onEnded {
                                        galleryConfig.quicklookImage(sdi)
                                    })
                                    .simultaneousGesture(TapGesture().onEnded {
                                        selection = sdi.id
                                    })
                                    .contextMenu {
                                        Section {
                                            Button {
                                                copyToPrompt(sdi)
                                            } label: {
                                                Text(
                                                    "Copy Options to Sidebar",
                                                    comment: "Copy the currently selected image's generation options to the prompt input sidebar"
                                                )
                                            }
                                            Button {
                                                galleryConfig.uscaleImage(sdi: sdi)
                                            } label: {
                                                Text(
                                                    "Convert to High Resolution",
                                                    comment: "Convert the current image to high resolution"
                                                )
                                            }
                                            Button(action: sdi.save) {
                                                Text(
                                                    "Save As...",
                                                    comment: "Show the save image dialog"
                                                )
                                            }
                                        }
                                        Section {
                                            Button {
                                                imageStore.remove(sdi: sdi)
                                            } label: {
                                                Text(
                                                    "Remove",
                                                    comment: "Remove image from the gallery"
                                                )
                                            }
                                        }
                                    }
                            }
                        }
                        .quickLookPreview($galleryConfig.quicklookURL)
                        .padding()
                    }
                }
            } else {
                Color.clear
            }
        }
        .searchable(text: $galleryConfig.searchText, prompt: "Search")
        .background(
            Image(systemName: "circle.fill")
                .resizable(resizingMode: .tile)
                .foregroundColor(Color.black.opacity(colorScheme == .dark ? 0.05 : 0.02))
        )
        .navigationTitle(
            galleryConfig.searchText.isEmpty ?
                "Mochi Diffusion" :
                String(
                    localized: "Searching: \(galleryConfig.searchText)",
                    comment: "Window title bar label displaying the searched text"
                )
        )
        .navigationSubtitle(galleryConfig.searchText.isEmpty ? "^[\(imageStore.images.count) images](inflect: true)" : "")
        .toolbar {
            GalleryToolbarView()
        }
    }

    var searchResults: [SDImage] {
        if $galleryConfig.searchText.wrappedValue.isEmpty {
            return imageStore.images
        }
        return imageStore.images.filter { $0.prompt.lowercased().contains(galleryConfig.searchText.lowercased())
        }
    }
}
