//
//  WorkoutView.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/2/24.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Query var workouts: [WorkoutModel]
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Workout")
                .font(.title)
            Grid(
                alignment: .leading,
                horizontalSpacing: 20,
                verticalSpacing: 20) {
                    ForEach(workouts) { workout in
                        GridRow {
                            Text("Set")
                            ForEach(Array(workout.sets), id: \.self) { set in
                                Text("\(set)")
                            }
                        }
                        GridRow {
                            Text("Rest")
                            ForEach(Array(workout.rests), id: \.self) { rest in
                                Text("\(rest)")
                            }
                        }
                    }
                    
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                }
            
                .padding()
        }
    }
}

#Preview {
    WorkoutView()
        .modelContainer(WorkoutModel.preview)
}
