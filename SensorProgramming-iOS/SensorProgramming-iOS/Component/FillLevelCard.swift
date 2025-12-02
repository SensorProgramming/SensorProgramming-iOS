//
//  FillLevelCard.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct FillLevelCard: View {
    let status: BinStatus
    
    var fillPercentage: Double {
        // 센서 값으로만 계산 (거리와 무게 중 높은 값 사용)
        // 거리 센서: 0cm = 0%, 20cm = 100%
        let maxDistance = 16.0  // 이 값이면 100%
        let heightPercent = min(100, (status.distanceCm / maxDistance) * 100)
        
        let maxWeight = 6.0   // 쓰레기통 최대 무게 (kg)
        let weightPercent = min(100, (status.weightKg / maxWeight) * 100)
        
        // 두 값 중 높은 값을 사용
        return max(heightPercent, weightPercent)
    }
    
    // 80% 이상인지 체크
    var isNearFull: Bool {
        return fillPercentage >= 80
    }
    
    // 100% 또는 그 이상인지 체크
    var isFull: Bool {
        return fillPercentage >= 100
    }
    
    var isSensorError: Bool {
        return false
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
                
                // 경고 메시지 - 센서 값 기반으로 판단
                if isFull {
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
                } else if isNearFull {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("쓰레기통이 80% 이상 찼습니다.")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
