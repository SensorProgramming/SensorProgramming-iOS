//
//  SensorCard.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct SensorCard: View {
    let title: String
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
                
                Text(value)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .frame(height: 150)
    }
}
