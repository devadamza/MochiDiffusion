//
//  SchedulerView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 12/26/22.
//

import StableDiffusion
import SwiftUI

struct SchedulerView: View {
    @Binding var scheduler: StableDiffusionScheduler

    var body: some View {
        Text(
            "Scheduler:",
            comment: "Label for Scheduler picker"
        )
        Picker("", selection: $scheduler) {
            ForEach(StableDiffusionScheduler.allCases, id: \.self) { scheduler in
                Text(scheduler.rawValue).tag(scheduler)
            }
        }
        .labelsHidden()
    }
}
