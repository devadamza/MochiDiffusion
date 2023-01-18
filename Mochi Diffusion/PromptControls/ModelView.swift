//
//  ModelView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/26/22.
//

import CoreML
import SwiftUI

struct ModelView: View {
    @Binding var models: [String]
    @Binding var currentModel: String
    var loadModels: () -> Void

    var body: some View {
        Text(
            "Model:",
            comment: "Label for Model picker"
        )
        HStack {
            Picker("", selection: $currentModel) {
                ForEach(models, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .labelsHidden()

            Button {
                loadModels()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(minWidth: 18)
            }
        }
    }
}
