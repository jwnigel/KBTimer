//
//  TimerView.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/2/24.
//

import SwiftUI
import Combine
import AVFoundation
import SwiftData


struct TimerView: View {
    
//    @Query(sort: [SortDescriptor(\WorkoutModel.order)]) var workouts: [WorkoutModel]
        
    
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timerSubscription: Cancellable? = nil
    @State var timerStarted: Bool = false
    
//    var currentWorkout: WorkoutModel? {
//        return workouts.first { workout in
//            return workout.completed == false
//        }
//    }
//    
//    var currentSet: TimedSet {
//        return (currentWorkout?.sets.first { $0.isCompleted == false })!
//    }
    
    private var progress: CGFloat {
        return CGFloat(max(0, min(1, Double(workoutManager.currentSet!.secondsRemaining) / Double(workoutManager.currentSet!.totalSeconds))))
    }
    
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                VStack(alignment: .leading) {
                    Grid(
                        alignment: .leading,
                        horizontalSpacing: 25,
                        verticalSpacing: 16) {
                            GridRow {
                                Text("Set")
                                    .font(.title2.weight(.medium))
                                    .frame(width: 50, alignment: .leading)
                                ForEach(Array(workoutManager.combinedSets)) { set in
                                    ZStack {
                                        Circle()
                                            .stroke(set.isCompleted ? .indigo : Color(.white), 
                                                    lineWidth: set.isCompleted ? 4 : 8)
                                            .fill(.indigo.opacity(0.3))
                                            .frame(width: 42)
                                        Text("\(set.minutes)")
                                            .font(.title3)
                                    }
                                }
                            }
                            GridRow {
                                Text("Rest")
                                    .font(.title2.weight(.medium))
                                    .frame(width: 50, alignment: .leading)
                                ForEach(Array(workoutManager.restSets ?? [TimedSet(minutes: 0)]), id: \.self) { rest in
                                    Text("\(rest)")
                                        .font(.title3)
                                    
                                }
                                
                            }
                        }
                    
                    
                }
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            
            
            Spacer()
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.yellow, lineWidth: 42)
                    .frame(width: 290, height: 290)
                
                // Foreground Circle representing progress
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.indigo, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .frame(width: 290, height: 290)
                    .rotationEffect(.degrees(-90)) // Start from the top
                    .animation(.easeInOut(duration: 1.5), value: progress)
                
                // Percentage Label
                Text(timerStarted ? String(format: "%.0f", workoutManager.currentSet!.secondsRemaining) : "Tap to begin")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .shadow(radius: 10, x: -2, y: 2)
            }


//            .onTapGesture(count: 2) {
//                resetTimer()
//            }
            
            .onTapGesture {
                if !timerStarted {
                    workoutManager.startWorkout()
                    timerStarted = true
                } else {
                    workoutManager.currentSet?.pause()
                    timerStarted = false
                        
                    
                }
                
            }
            
            Spacer()
            
        }
        .padding()
        
    }
    
    
    
//    func startTimer() {
//        
//        timerSubscription?.cancel()
//        playDing(for: "brightPing2")
//        
//        timerSubscription = Timer.publish(
//            every: 1,
//            on: .main,
//            in: .default
//        )
//        .autoconnect()
//        .sink { _ in
//            if currentSet.secondsRemaining > 0 {
//                currentSet.reduceSecond()
//            } else {
//                stopTimer()
//            }
//        }
//    }
    
    
//    func stopTimer() {
//        timerSubscription?.cancel()
//        timerSubscription = nil
//        //        playDing(for: "brightPing2")
//        // TODO: add stop timer mp3
//    }
    
//    func resetTimer() {
//        currentSet.resetTime()
//        startTimer()
//    }
    
    func playDing(for resourceName: String) {
        // Ensure the sound file exists
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        // Create an AVAudioPlayer instance and play the sound
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}



#Preview {
    TimerView()
        .environment(WorkoutManager(workoutSets: [TimedSet(minutes: 1), TimedSet(minutes: 1)],
                                    restSets: [TimedSet(minutes: 2)]))
//        .modelContainer(WorkoutModel.preview)
}
