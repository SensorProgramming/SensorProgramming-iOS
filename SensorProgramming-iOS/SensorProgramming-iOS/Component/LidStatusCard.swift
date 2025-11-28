//
//  LidStatusCard.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct LidStatusCard: View {
    let lidOpen: Bool
    let timestamp: Date
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(lidOpen ? Color.green : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(lidOpen ? Color.white : Color.green)
                            .frame(width: 12, height: 12)
                            .opacity(isAnimating ? 0.5 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                        
                        Text("뚜껑 \(lidOpen ? "열림" : "닫힘")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(lidOpen ? .white : .primary)
                    }
                    
                    Text("마지막 동작: \(timestamp, style: .relative)")
                        .font(.caption)
                        .foregroundColor(lidOpen ? Color.white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                Text("🚪")
                    .font(.system(size: 60))
                    .rotationEffect(.degrees(lidOpen ? 45 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: lidOpen)
            }
            .padding()
        }
        .frame(height: 120)
        .onAppear {
            isAnimating = true
        }
    }
}
