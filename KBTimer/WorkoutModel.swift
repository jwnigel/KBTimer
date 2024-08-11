//
//  WorkoutModel.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/4/24.


import SwiftData

enum SetType: String, Codable {
    case set
    case rest
}


@Model
class WorkoutModel {
    let order: Int
    let sets: [TimedSet]
    let rests: [TimedSet]?
    var isBegun: Bool = false
    var isCompleted: Bool = false
    var currentSet: TimedSet?
    var currentIdx: Int = 0
    var currentSetType: String = "set"
    
    init(order: Int, sets: [TimedSet], rests: [TimedSet]?, isCompleted: Bool, currentIdx: Int, currentSetType: String) {
        self.order = order
        self.sets = sets
        self.rests = rests
        self.isCompleted = isCompleted
        self.currentIdx = currentIdx
        self.currentSetType = currentSetType
        
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
}


extension WorkoutModel {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: WorkoutModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(WorkoutModel(
            order: 0,
            sets: [TimedSet(minutes: 2, isCompleted: true), TimedSet(minutes: 1)],
            rests: [TimedSet(minutes: 1)],
            isCompleted: false,
            currentIdx: 0,
            currentSetType: "rest"
        ))
        
        return container
    }
    
    
    func oneSecondPasses() {
        currentSet?.secondsRemaining -= 1
        if currentSet?.secondsRemaining == 0 {
            currentSet?.isCompleted = true
            beginNextSet()
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



