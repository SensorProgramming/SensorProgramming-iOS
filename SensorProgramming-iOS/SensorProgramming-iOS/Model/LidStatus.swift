//
//  LidStatus.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct LidStatus: Codable {
    let lidOpen: Bool
    let lidState: String
    let timestamp: String
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
        case lidOpen = "lid_open"
        case lidState = "lid_state"
        case timestamp = "ts"
        case deviceId = "device_id"
    }
}
