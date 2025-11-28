//
//  MainTabView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var service = SmartBinService()
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(service)
                .tabItem {
                    Label("대시보드", systemImage: "house.fill")
                }
            
            SensorDetailView()
                .environmentObject(service)
                .tabItem {
                    Label("센서", systemImage: "chart.bar.fill")
                }
            
            LogsView()
                .environmentObject(service)
                .tabItem {
                    Label("알림", systemImage: "bell.fill")
                }
        }
        .accentColor(.indigo)
    }
}
