//
//  LogsView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct LogsView: View {
    @EnvironmentObject var service: SmartBinService
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if service.logs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("알림이 없습니다")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(service.logs) { log in
                            LogRowView(log: log)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("알림 기록")
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
