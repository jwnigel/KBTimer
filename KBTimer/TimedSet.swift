//
//  TimedSet.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/7/24.
//

import Foundation
import Combine
import Observation

class TimedSet: ObservableObject, Identifiable, Hashable {
    static func == (lhs: TimedSet, rhs: TimedSet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @Published var isCompleted: Bool
    @Published var secondsRemaining: Int

    
    var id = UUID()
    var minutes: Int
    
    var totalSeconds: Int {
        minutes * 60
    }
    
    private var cancellable: AnyCancellable?
    
    init(minutes: Int, isCompleted: Bool = false) {
        self.minutes = minutes
        self.secondsRemaining = minutes * 60
        self.isCompleted = isCompleted
    }
    
    func startTimer() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.secondsRemaining > 1 {
                    self.secondsRemaining -= 1
                } else {
                    self.isCompleted = true
                    self.cancellable?.cancel()
                }
                print(self.secondsRemaining)
            }
    }
    
    func pause() {
        cancellable?.cancel()
    }
}

@Observable class WorkoutManager {
    var workoutSets: [TimedSet]
    var restSets: [TimedSet]?
    var combinedSets: [TimedSet]
    var currentSet: TimedSet?
    
    private var cancellables = Set<AnyCancellable>()
    init(workoutSets: [TimedSet], restSets: [TimedSet]) {
        self.workoutSets = workoutSets
        self.restSets = restSets
        self.combinedSets = []
        for (idx, workoutSet) in workoutSets.enumerated() {
            combinedSets.append(workoutSet)
            if idx < restSets.count {
                combinedSets.append(restSets[idx])
            }
        }
        self.currentSet = combinedSets.first
        print("Combined sets: \(self.combinedSets)")
    }
    
    func startWorkout() {
        startNextSet(idx: 0)
    }
    
    private func startNextSet(idx: Int) {
        guard idx < combinedSets.count else {
            print("All workouts and rests completed.")
            return
        }
        
        currentSet = combinedSets[idx]
        currentSet?.startTimer()
        
        currentSet?.$isCompleted
            .filter { $0 }
            .first()
            .sink { [weak self] _ in
                print("Completed set \(idx + 1)")
                self?.startNextSet(idx: idx + 1)
            }
            .store(in: &cancellables)
    }
}
