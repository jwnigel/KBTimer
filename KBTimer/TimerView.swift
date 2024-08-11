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

    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\WorkoutModel.order)]) var workouts: [WorkoutModel]
    @State var currentWorkout: WorkoutModel?
    @State var currentWorkoutSet: TimedSet?
    
    @State private var timerSubscription: Cancellable? = nil
    @State var timerStarted: Bool = false
    
    init() {
         if let firstWorkout = workouts.first(where: { !$0.isCompleted }) {
             self._currentWorkout = State(initialValue: firstWorkout)
             self._currentWorkoutSet = State(initialValue: firstWorkout.currentSet)
         }
     }
    
    @State private var audioPlayer: AVAudioPlayer?
        
    private var formattedTime: String {
        guard let currentSet = currentWorkout?.currentSet else {
            return "00:00"
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        
        let totalSeconds = currentSet.secondsRemaining
        return formatter.string(from: TimeInterval(totalSeconds)) ?? "00:00"
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
                                ForEach(Array(currentWorkout?.sets ?? [TimedSet(minutes: 0)])) { set in
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
                                ForEach(Array(currentWorkout?.rests ?? [TimedSet(minutes: 0)]), id: \.self) { rest in
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
                    .trim(from: 0, to: currentWorkoutSet?.progress ?? 0.5)
                    .stroke(Color.indigo, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .frame(width: 290, height: 290)
                    .rotationEffect(.degrees(-90)) // Start from the top
                    .animation(.easeInOut(duration: 1.5), value: currentWorkoutSet?.progress)
                
                Text(timerStarted ? formattedTime : "Tap to begin")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .shadow(radius: 10, x: -2, y: 2)
            }


//            .onTapGesture(count: 2) {
//                resetTimer()
//            }
            
            .onTapGesture {
                if !timerStarted {
                    startTimer()
                    timerStarted = true
                } else {
                    pauseTimer()
                    timerStarted = false
                        
                    
                }
            }
            
            Spacer()
            
        }
        .padding()
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
                currentWorkout?.oneSecondPasses()
            }
        }
    
    
    func pauseTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        playDing(for: "brightPing2")
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
//        .modelContainer(WorkoutModel.preview)
}
