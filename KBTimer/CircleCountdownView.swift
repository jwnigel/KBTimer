//
//  CircleCountdownView.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/11/24.
//

import SwiftUI


struct CircleCountdownView: View {
    @Binding var workout: WorkoutModel?
    @Binding var timerStarted: Bool

    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.secondarySystemBackground), lineWidth: 42)
                .frame(width: 290, height: 290)
                .shadow(
                    color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.4),
                    radius: 4,
                    x: 1,
                    y: 1
                )
                .background(Circle().fill(.white).shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4))

            
            Circle()
                .trim(from: 0, to: workout?.progress ?? 1.0)
                .stroke(workout?.currentSetType == "rest" ? Color.blue : Color.mint , style: StrokeStyle(lineWidth: 34, lineCap: .round))
                .frame(width: 290, height: 290)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.5), value: workout?.progress)

            
            Text(((timerStarted ? workout?.formattedTime : "Tap to begin") ?? "00:00"))
                .font(timerStarted ? .largeTitle : .extraLarge)
                .fontWeight(timerStarted ? .bold : .regular)
                .foregroundStyle(.secondary)
                .shadow(color: .black.opacity(0.3), radius: 1, x: -1, y: 1)
        }
    }
}

// TODO -- How to get preview working?
