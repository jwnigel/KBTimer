//
//  TimerView.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/2/24.
//

import SwiftUI
import Combine
import AVFoundation

struct CircularProgressView: View {
    @State private var audioPlayer: AVAudioPlayer?
    private var progress: CGFloat {
        return max(0, min(1, timeRemaining / totalTime))
    }
    @Binding var timerStarted: Bool
    @State var totalTime: CGFloat
    @State var timeRemaining: CGFloat
    @State private var timerSubscription: Cancellable? = nil
    
    
    var body: some View {
        
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 42)
                .frame(width: 300, height: 300)
            
            // Foreground Circle representing progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.indigo, style: StrokeStyle(lineWidth: 35, lineCap: .round))
                .frame(width: 300, height: 300)
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
        timeRemaining = totalTime
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

struct TimerView: View {
    
    @State var timerStarted: Bool = false
    
    var body: some View {
        VStack {
            CircularProgressView(
                timerStarted: $timerStarted,
                totalTime: 60,
                timeRemaining: 60
            )
        }
        .padding()
    }
    
}



#Preview {
    TimerView()
}
