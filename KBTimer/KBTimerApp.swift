//
//  KBTimerApp.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/2/24.
//

import SwiftUI

@main
struct KBTimerApp: App {
    var body: some Scene {
        WindowGroup {
            TimerView()
                .environment(WorkoutManager(workoutSets: [TimedSet(minutes: 1), TimedSet(minutes: 1)],
                                            restSets: [TimedSet(minutes: 2)]))
        }
    }
}
