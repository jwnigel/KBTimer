//
//  KBTimerApp.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/2/24.
//

import SwiftUI
import SwiftData

@main
struct KBTimerApp: App {
    var body: some Scene {
        WindowGroup {
            TimerView()
                .modelContainer(WorkoutModel.preview)
        }
    }
}
