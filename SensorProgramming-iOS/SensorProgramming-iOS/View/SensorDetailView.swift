//
//  SensorDetailView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct SensorDetailView: View {
    @EnvironmentObject var service: SmartBinService
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if service.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if let status = service.binStatus {
                                // 실시간 센서 데이터
                                SensorCard(
                                    title: "초음파 센서",
                                    icon: "ruler",
                                    value: String(format: "%.1f cm", status.distanceCm),
                                    color: .blue
                                )
                                
                                SensorCard(
                                    title: "로드셀 센서",
                                    icon: "scalemass",
                                    value: String(format: "%.2f kg", status.weightKg),
                                    color: .green
                                )
                                
                                // 상태 표시 - 센서 값 기반으로 계산
                                let maxDistance = 20.0
                                let heightPercent = min(100, (status.distanceCm / maxDistance) * 100)
                                let maxWeight = 6.0
                                let weightPercent = min(100, (status.weightKg / maxWeight) * 100)
                                let fillPercentage = max(heightPercent, weightPercent)
                                
                                StatusCard(
                                    title: "부피 기준",
                                    items: [
                                        ("만차", fillPercentage >= 100 ? "예" : "아니오", fillPercentage >= 100),
                                        ("80% 이상", fillPercentage >= 80 ? "예" : "아니오", fillPercentage >= 80)
                                    ]
                                )
                                
                                StatusCard(
                                    title: "무게 기준",
                                    items: [
                                        ("만차", weightPercent >= 100 ? "예" : "아니오", weightPercent >= 100)
                                    ]
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("센서 데이터")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await service.fetchData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.indigo)
                    }
                }
            }
        }
    }
}
