//
//  LogRowView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct LogRowView: View {
    let log: ActivityLog
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.message)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(log.time, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(log.type.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(log.type.color.opacity(0.3), lineWidth: 1)
        )
    }
}
