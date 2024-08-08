//
//  WorkoutSet.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/7/24.
//

import Foundation
import SwiftData

@Model
class WorkoutSet {
    let minutes: Int
    var isCompleted: Bool
    
    init(minutes: Int, completed: Bool) {
        self.minutes = minutes
        self.isCompleted = completed
    }
    

}
