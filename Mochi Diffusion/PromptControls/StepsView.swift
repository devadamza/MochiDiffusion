//
//  StepsView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/26/22.
//

import Sliders
import SwiftUI

struct StepsView: View {
    @Binding var steps: Int
    private let controlHeight: CGFloat = 12

    var body: some View {
        Text(
            "Steps: \(steps)",
            comment: "Label for Steps slider with value"
        )
        ValueSlider(value: $steps, in: 2 ... 100, step: 1)
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

struct StepsView_Previews: PreviewProvider {
    static var previews: some View {
        StepsView(steps: .constant(20))
    }
}
