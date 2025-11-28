//
//  FillLevelCard.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct FillLevelCard: View {
    let status: BinStatus
    
    // TODO: - 추후 정확하게 변경
    var fillPercentage: Double {
        let maxHeight = 30.0
        let heightPercent = max(0, min(100, ((maxHeight - status.distanceCm) / maxHeight) * 100))
        
        let maxWeight = 6.0
        let weightPercent = min(100, (status.weightKg / maxWeight) * 100)
        
        return max(heightPercent, weightPercent)
    }
    
    var fillColor: Color {
        if fillPercentage >= 80 { return .red }
        if fillPercentage >= 40 { return .orange }
        return .green
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 20) {
                Text("적재량")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 원형 게이지
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: fillPercentage / 100)
                        .stroke(fillColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: fillPercentage)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(fillPercentage))%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(fillColor)
                        
                        Text("적재량")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 상세 정보
                HStack(spacing: 12) {
                    DetailBox(
                        icon: "scalemass",
                        label: "무게",
                        value: String(format: "%.1f kg", status.weightKg),
                        color: fillColor
                    )
                    
                    DetailBox(
                        icon: "ruler",
                        label: "높이",
                        value: String(format: "%.0f cm", status.distanceCm),
                        color: fillColor
                    )
                }
                
                // 경고 메시지
                if fillPercentage >= 80 {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("쓰레기통이 가득 찼습니다!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
