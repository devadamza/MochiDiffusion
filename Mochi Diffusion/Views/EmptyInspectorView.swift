//
//  EmptyInspectorView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/18/23.
//

import SwiftUI

struct EmptyInspectorView: View {
    var body: some View {
        Text(
            "No Info",
            comment: "Placeholder text for image inspector"
        )
        .font(.title2)
        .foregroundColor(.secondary)
    }
}

struct EmptyInspectorView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyInspectorView()
    }
}
