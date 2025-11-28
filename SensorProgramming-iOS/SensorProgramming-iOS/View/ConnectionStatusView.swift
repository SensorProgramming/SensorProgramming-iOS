//
//  ConnectionStatusView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct ConnectionStatusView: View {
    let isConnected: Bool
    let lastUpdate: Date?
    
    var body: some View {
        HStack {
            Image(systemName: isConnected ? "wifi" : "wifi.slash")
                .foregroundColor(isConnected ? .green : .red)
            Text(isConnected ? "연결됨" : "연결 끊김")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let lastUpdate = lastUpdate {
                Text("•")
                    .foregroundColor(.secondary)
                Text(lastUpdate, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}
