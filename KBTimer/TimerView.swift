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
    
    @State private var timerSubscription: Cancellable? = nil
    @State var timerStarted: Bool = false
    
    @State private var audioPlayer: AVAudioPlayer?
       
    var body: some View {
        
        VStack {
            
            HStack {
                VStack(alignment: .leading) {
                    Grid(
                        alignment: .leading,
                        horizontalSpacing: 24,
                        verticalSpacing: 16) {
                            GridRow {
                                Text("Set")
                                    .font(.title2.weight(.medium))
                                    .frame(width: 50, alignment: .leading)
                                ForEach(currentWorkout?.sets.sorted(by: { $0.order < $1.order }) ?? [TimedSet(order: 1, minutes: 0)]) { set in
                                    ZStack {
                                        Circle()
                                            .fill(Gradient(colors: [.mint.opacity(0.2), .mint.opacity(0.4)]))
                                            .stroke(set.isCompleted ? .mint : Color(.white),
                                                    lineWidth: 3)
                                            .frame(width: 42)
                                        Text("\(set.minutes)")
                                            .font(.title3)
                                    }
                                    .shadow(radius: 2)
                                }
                            }
                            GridRow {
                                Text("Rest")
                                    .font(.title2.weight(.medium))
                                    .frame(width: 50, alignment: .leading)
                                ForEach(currentWorkout?.rests?.sorted(by: { $0.order < $1.order }) ?? [TimedSet(order: 0, minutes: 0)], id: \.self) { rest in
                                    ZStack {
                                        Circle()
                                            .fill(Gradient(colors: [.blue.opacity(0.2), .blue.opacity(0.4)]))
                                            .stroke(rest.isCompleted ? .blue : Color(.white),
                                                    lineWidth: 3)
                                            .frame(width: 42)
                                        Text("\(rest.minutes)")
                                            .font(.title3)
                                    }
                                    .shadow(radius: 2)
                                    .offset(x: 21 + 12 )  // 21 for half the frame width and 12 for half the horizontal spacing
                                }
                            }
                        }
                }
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            
            Spacer()
            
            if let currentWorkout = currentWorkout {
                CircleCountdownView(
                    workout: $currentWorkout,
                    timerStarted: $timerStarted
                )
                .onTapGesture(count: 2) {
                    resetTimer()
                    timerStarted = false
                }
                .onTapGesture {
                    if !timerStarted {
                        startTimer()
                        timerStarted = true
                    } else {
                        pauseTimer()
                        timerStarted = false
                    }
                }
            }
            
            Spacer()
            
        }
        .padding()
        .onAppear {
            // workoutManager.getCurrentWorkout()
            if let firstWorkout = workouts.sorted(by: { $0.order < $1.order }).first(where: { $0.isCompleted == false }) {
                currentWorkout = firstWorkout
            }
        }
    }
    
    func startTimer() {
        timerSubscription?.cancel()
        playDing(for: "brightPing2")
        currentWorkout!.isBegun = true
        currentWorkout!.updateCurrentSet()
        
        timerSubscription = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                currentWorkout?.oneSecondPasses()
            }
    }
    
    func resetTimer() {
        timerSubscription?.cancel()
        currentWorkout!.currentSet!.secondsRemaining = currentWorkout!.currentSet!.minutes * 60
    }
    
    func pauseTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        playDing(for: "brightPing2")
    }
    
    func playDing(for resourceName: String) {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
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
