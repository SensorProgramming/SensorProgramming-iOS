//
//  DashboardView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct DashboardView: View {
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
                            ConnectionStatusView(
                                isConnected: service.isConnected,
                                lastUpdate: service.lastUpdate
                            )
                            
                            if let status = service.binStatus {
                                LidStatusCard(lidOpen: status.lidOpen, timestamp: status.timestamp)
                                FillLevelCard(status: status)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("스마트 쓰레기통")
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
