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
    let order: Int
    let minutes: Int
    var secondsRemaining: Int
    var isCompleted: Bool = false
    
    init(order: Int, minutes: Int, isCompleted: Bool = false) {
        self.order = order
        self.minutes = minutes
        self.secondsRemaining = minutes * 10
        self.isCompleted = isCompleted
    }
}
