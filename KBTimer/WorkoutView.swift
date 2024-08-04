//
//  WorkoutView.swift
//  KBTimer
//
//  Created by Nigel Wright on 8/2/24.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Query(sort: \WorkoutModel.order) var workouts: [WorkoutModel]
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("All Workouts")
                .font(.title).fontWeight(.medium)
            ScrollView {
                ForEach(workouts) { workout in
                    
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
                                        ForEach(Array(workout.sets), id: \.self) { set in
                                            Text("\(set)")
                                                .font(.title3)
                                        }
                                    }
                                    
                                    GridRow {
                                        Text("Rest")
                                            .font(.title2.weight(.medium))
                                            .frame(width: 50, alignment: .leading)
                                        ForEach(Array(workout.rests), id: \.self) { rest in
                                            Text("\(rest)")
                                                .font(.title3)
                                            
                                        }
                                        
                                    }
                                }
                            
                            
                        }
                        Spacer()
                        Image(systemName: workout.viewCompleted)
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 35)
                            .padding(.trailing, 6)
                        
                    }
                    .frame(width: 320, height: 85, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.indigo.opacity(workout.completed ? 0.6 : 0.18)))
                }
            }
        }
        .padding()
        
    }
}

#Preview {
    WorkoutView()
        .modelContainer(WorkoutModel.preview)
}
