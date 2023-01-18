//
//  GuidanceScaleView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/26/22.
//

import Sliders
import SwiftUI

struct GuidanceScaleView: View {
    @Binding var guidanceScale: Double
    private let controlHeight: CGFloat = 12

    var body: some View {
        Text(
            "Guidance Scale: \(guidanceScale.formatted(.number.precision(.fractionLength(1))))",
            comment: "Label for Guidance Scale slider with value"
        )
        ValueSlider(value: $guidanceScale, in: 1 ... 20, step: 0.5)
            .valueSliderStyle(
                HorizontalValueSliderStyle(
                    track:
                        HorizontalTrack(view: Color.accentColor)
                        .frame(height: controlHeight)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius((controlHeight / 2).rounded(.down)),
                    thumbSize: CGSize(width: controlHeight, height: controlHeight),
                    options: .interactiveTrack
                )
            )
            .frame(height: controlHeight)
    }
}

struct GuidanceScaleView_Previews: PreviewProvider {
    static var previews: some View {
        GuidanceScaleView(guidanceScale: .constant(11))
    }
}
