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
    
    @Query(sort: [SortDescriptor(\WorkoutModel.order)]) var workouts: [WorkoutModel]
    
    var firstIncompleteWorkout: WorkoutModel? {
        return workouts.first { workout in
            return workout.completed == false
        }
    }
    
    var firstIncompleteSet: WorkoutSet? {
        return firstIncompleteWorkout?.sets.first { $0.isCompleted == false }
    }
    
    @State private var audioPlayer: AVAudioPlayer?
    private var progress: CGFloat {
        return max(0, min(1, timeRemaining / CGFloat(firstIncompleteSet!.minutes)))
    }
//    @State var timeRemaining: CGFloat
    @State private var timerSubscription: Cancellable? = nil
    @State var timerStarted: Bool = false
    
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
                                ForEach(Array(firstIncompleteWorkout?.sets.sorted {
                                    $0.isCompleted && !$1.isCompleted
                                } ?? [WorkoutSet(minutes: 5, completed: false)]), id: \.self) { set in
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
                                ForEach(Array(firstIncompleteWorkout?.rests ?? [0]), id: \.self) { rest in
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
                Text(timerStarted ? String(format: "%.0f", timeRemaining) : "Tap to begin")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .shadow(radius: 10, x: -2, y: 2)
            }


            .onTapGesture(count: 2) {
                resetTimer()
            }
            
            .onTapGesture {
                if !timerStarted {
                    startTimer()
                    timerStarted = true
                } else {
                    stopTimer()
                    timerStarted = false
                    
                }
                
            }
            
            Spacer()
            
        }
        
    }
    
    
    
    func startTimer() {
        
        timerSubscription?.cancel()
        playDing(for: "brightPing2")
        
        timerSubscription = Timer.publish(
            every: 1,
            on: .main,
            in: .default
        )
        .autoconnect()
        .sink { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    
    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        //        playDing(for: "brightPing2")
        // TODO: add stop timer mp3
    }
    
    func resetTimer() {
        timeRemaining = CGFloat(firstIncompleteSet!.minutes)
        startTimer()
    }
    
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
        .modelContainer(WorkoutModel.preview)
}
