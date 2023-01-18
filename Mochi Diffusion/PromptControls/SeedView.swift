//
//  SeedView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/26/22.
//

import SwiftUI

struct SeedView: View {
    @Binding var seed: UInt32
    @FocusState private var randomFieldIsFocused: Bool

    var body: some View {
        Text(
            "Seed:",
            comment: "Label for Seed text field"
        )
        HStack {
            TextField("random", value: $seed, formatter: Formatter.seedFormatter)
                .focused($randomFieldIsFocused)
                .textFieldStyle(.roundedBorder)
            Button {
                randomFieldIsFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // TODO: Find reliable way to clear textfield
                    seed = 0
                }
            } label: {
                Image(systemName: "shuffle")
                    .frame(minWidth: 18)
            }
        }
    }
}
