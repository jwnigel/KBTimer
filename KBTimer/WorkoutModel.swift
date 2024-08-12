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
        self.sets = sets.sorted(by: { $0.order < $1.order })
        self.rests = rests?.sorted(by: { $0.order < $1.order })
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
        let container = try! ModelContainer(for: WorkoutModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(WorkoutModel(
            order: 0,
            sets: [TimedSet(order: 1, minutes: 2, isCompleted: true), TimedSet(order: 2, minutes: 1), TimedSet(order: 3, minutes: 1)],
            rests: [TimedSet(order: 1, minutes: 1, isCompleted: true), TimedSet(order: 2, minutes: 2)],
            isBegun: false,
            isCompleted: false,
            currentIdx: 1,
            currentSetType: "set"
        ))
        
        return container
    }
    
    func updateCurrentSet() {
        if isBegun {
            if currentSetType == "set" {
                self.currentSet = sets.first(where: { !$0.isCompleted })
            } else if currentSetType == "rest" {
                self.currentSet = rests?.first(where: { !$0.isCompleted })
            }
            print("Current set initialized: \(currentSet)")
        } else {
            self.currentSet = nil
        }
    }
    
    func oneSecondPasses() {
        if !isCompleted {
            if currentSet?.secondsRemaining == 0 {
                currentSet?.isCompleted = true
                updateCurrentSet()
                beginNextSet()
            } else {
                currentSet?.secondsRemaining -= 1
            }
        }
    }
    
    func beginNextSet() {
        if currentIdx == sets.count - 1 {
            //TODO
            // endWorkout()
            currentSet?.isCompleted = true
            isCompleted = true
        } else if currentSetType == "rest" {
            currentIdx += 1
            currentSet = sets.sorted(by: { $0.order < $1.order }).first(where: { $0.isCompleted == false })
            currentSetType = "set"
        } else if currentSetType == "set" {
            currentSet = rests?.sorted(by: { $0.order < $1.order }).first(where: { $0.isCompleted == false })
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


