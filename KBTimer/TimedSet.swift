//
//  TimedSet.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/7/24.
//

import Foundation
import SwiftData

@Model
class TimedSet {
    var id = UUID()
    let minutes: Int
    var secondsRemaining: Int
    var isCompleted: Bool = false
    
    init(minutes: Int, isCompleted: Bool = false) {
        self.minutes = minutes
        self.secondsRemaining = minutes * 60
        self.isCompleted = isCompleted
    }
}
