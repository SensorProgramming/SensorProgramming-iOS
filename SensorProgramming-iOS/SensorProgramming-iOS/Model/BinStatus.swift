//
//  BinStatus.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct BinStatus {
    let lidOpen: Bool
    let isFull: Bool
    let fullByVolume: Bool
    let fullByWeight: Bool
    let nearFullByVolume: Bool
    let distanceCm: Double
    let weightKg: Double
    let timestamp: Date
}
