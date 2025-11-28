//
//  ActivityLog.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct ActivityLog: Identifiable {
    let id = UUID()
    let time: Date
    let message: String
    let type: LogType
    
    enum LogType {
        case danger, warning, info
        
        var color: Color {
            switch self {
            case .danger: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
    }
}
