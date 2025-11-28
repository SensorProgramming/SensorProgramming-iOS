//
//  FullnessStatus.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct FullnessStatus: Codable {
    let isFull: Bool
    let fullCase: String
    let fullByVolume: Bool
    let fullByWeight: Bool
    let nearFullByVolume: Bool
    let distanceCm: Double
    let weightKg: Double
    let timestamp: String
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
        case isFull = "is_full"
        case fullCase = "case"
        case fullByVolume = "full_by_volume"
        case fullByWeight = "full_by_weight"
        case nearFullByVolume = "near_full_by_volume"
        case distanceCm = "distance_cm"
        case weightKg = "weight_kg"
        case timestamp = "ts"
        case deviceId = "device_id"
    }
}
