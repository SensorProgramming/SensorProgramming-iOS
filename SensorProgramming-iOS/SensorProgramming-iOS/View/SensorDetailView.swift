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
                                
                                // 상태 표시
                                StatusCard(
                                    title: "부피 기준",
                                    items: [
                                        ("만차", status.fullByVolume ? "예" : "아니오", status.fullByVolume),
                                        ("80% 이상", status.nearFullByVolume ? "예" : "아니오", status.nearFullByVolume)
                                    ]
                                )
                                
                                StatusCard(
                                    title: "무게 기준",
                                    items: [
                                        ("만차", status.fullByWeight ? "예" : "아니오", status.fullByWeight)
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
