//
//  WorkoutModel.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/4/24.


import SwiftData
import Foundation

enum SetType: String, Codable {
    case set
    case rest
}


@Model
class WorkoutModel {
    let order: Int
    var sets: [TimedSet]
    var rests: [TimedSet]?
    var isBegun: Bool = false
    var isCompleted: Bool = false
    var currentSet: TimedSet?
    var currentIdx: Int = 0
    var currentSetType: String = "set"
    
    init(order: Int, sets: [TimedSet], rests: [TimedSet]?, isBegun: Bool, isCompleted: Bool, currentIdx: Int, currentSetType: String) {
        self.order = order
        self.sets = sets
        self.rests = rests
        self.isBegun = isBegun
        self.isCompleted = isCompleted
        self.currentIdx = currentIdx
        self.currentSetType = currentSetType
        
        self.updateCurrentSet()
    }
}


extension WorkoutModel {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: WorkoutModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
        
        container.mainContext.insert(WorkoutModel(
            order: 0,
            sets: [TimedSet(minutes: 2, isCompleted: true), TimedSet(minutes: 1), TimedSet(minutes: 1)],
            rests: [TimedSet(minutes: 1, isCompleted: true), TimedSet(minutes: 1)],
            isBegun: false,
            isCompleted: false,
            currentIdx: 0,
            currentSetType: "set"
        ))
        
        return container
    }
    
    func updateCurrentSet() {
        if isBegun {
            if currentSetType == "set" {
                self.currentSet = sets.indices.contains(currentIdx) ? sets[currentIdx] : nil
            } else if currentSetType == "rest" {
                self.currentSet = rests?.indices.contains(currentIdx) == true ? rests?[currentIdx] : nil
            }
            print("Current set initialized: \(currentSet)")
        } else {
            self.currentSet = nil
        }
    }
    
    func oneSecondPasses() {
        if currentSet?.secondsRemaining == 0 {
            currentSet?.isCompleted = true
            beginNextSet()
        } else {
            currentSet?.secondsRemaining -= 1

        }
    }
    
    func beginNextSet() {
        if currentIdx == sets.count - 1 {
            //TODO
            // endWorkout()
            isCompleted = true
        } else if currentSetType == "rest" {
            currentIdx += 1
            currentSet = sets[currentIdx]
            currentSetType = "set"
        } else if currentSetType == "set" {
            currentSet = rests?[currentIdx]
            currentSetType = "rest"
        } else {
            currentSet = nil
            print("No currentSet set in beginNextSet")
        }
    }
}


extension WorkoutModel {
    var progress: CGFloat {
        return max(0, min(1, CGFloat(currentSet?.secondsRemaining ?? 0) / CGFloat((currentSet?.minutes ?? 0) * 60)))
    }
    
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        
        return formatter.string(from: TimeInterval(currentSet?.secondsRemaining ?? 0)) ?? "00:00"
    }
}


