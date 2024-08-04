//
//  WorkoutModel.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/4/24.
//

import SwiftData


@Model
class WorkoutModel {
    let order: Int
    let sets: [Int]
    let rests: [Int]
    var completed: Bool = false
    
    init(order: Int, sets: [Int], rests: [Int], completed: Bool = false) {
        self.order = order
        self.sets = sets
        self.rests = rests
        self.completed = completed
    }
}


extension WorkoutModel {
    
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: WorkoutModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(WorkoutModel(order: 1, sets: [1, 1, 1, 1, 1], rests: [2, 2, 2, 2], completed: true))
        container.mainContext.insert(WorkoutModel(order: 2, sets: [2, 2, 2], rests: [2, 2], completed: true))
        container.mainContext.insert(WorkoutModel(order: 3, sets: [4], rests: [], completed: true))
        container.mainContext.insert(WorkoutModel(order: 4, sets: [1, 1, 1, 1, 1, 1, 1], rests: [1, 1, 1, 1, 1, 1], completed: false))
        container.mainContext.insert(WorkoutModel(order: 5, sets: [1, 2, 3, 2, 1], rests: [3, 3, 3, 3], completed: false))
        container.mainContext.insert(WorkoutModel(order: 6, sets: [5], rests: [], completed: false))
        container.mainContext.insert(WorkoutModel(order: 7, sets: [2, 2, 2, 2], rests: [2, 2, 2], completed: false))
        container.mainContext.insert(WorkoutModel(order: 8, sets: [4, 3, 2, 1], rests: [5, 4, 3], completed: false))
        container.mainContext.insert(WorkoutModel(order: 9, sets: [7], rests: [], completed: false))
        container.mainContext.insert(WorkoutModel(order: 10, sets: [3, 3, 3], rests: [5, 5], completed: false))
        
        
        return container
    }
}
