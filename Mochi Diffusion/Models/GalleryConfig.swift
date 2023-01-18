//
//  GalleryConfig.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/17/23.
//

import Foundation

struct GalleryConfig {
    var searchText = ""
    var quicklookURL: URL?

    mutating func setSearchText(_ search: String) {
        searchText = search
    }

    mutating func quicklookImage(_ sdi: SDImage) {
        guard let image = sdi.image else { return }
        quicklookURL = try? image.asNSImage().temporaryFileURL()
    }

    mutating func quicklookImage(_ id: SDImage.ID, imageStore: ImageStore) {
        guard let sdi = imageStore.image(with: id), let image = sdi.image else { return }
        quicklookURL = try? image.asNSImage().temporaryFileURL()
    }

    /// Remember to set returned SDImage.ID to selectedImageId
    mutating func selectImage(id: SDImage.ID, imageStore: ImageStore) -> SDImage.ID {
        // if quick look is already open show selected image
        if quicklookURL != nil {
            guard let sdi = imageStore.image(with: id) else { return id }
            quicklookImage(sdi)
        }
        return id
    }

    /// Remember to set returned SDImage.ID to selectedImageId
    mutating func selectPreviousImage(id: SDImage.ID, imageStore: ImageStore) -> SDImage.ID? {
        guard let index = imageStore.index(for: id) else { return nil }
        if index == 0 { return id }
        return selectImage(id: imageStore.images[index - 1].id, imageStore: imageStore)
    }

    /// Remember to set returned SDImage.ID to selectedImageId
    mutating func selectNextImage(id: SDImage.ID, imageStore: ImageStore) -> SDImage.ID? {
        guard let index = imageStore.index(for: id) else { return nil }
        if index == imageStore.images.count - 1 { return id }
        return selectImage(id: imageStore.images[index + 1].id, imageStore: imageStore)
    }
}
