//
//  SmartBinService.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

class SmartBinService: ObservableObject {
    @Published var binStatus: BinStatus?
    @Published var logs: [ActivityLog] = []
    @Published var isConnected = true
    @Published var isLoading = true
    @Published var lastUpdate: Date?
    
    private let baseURL = "http://15.165.212.56:8000"
    private var timer: Timer?
    
    // ISO8601 날짜 파서
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    init() {
        startAutoRefresh()
    }
    
    func fetchData() async {
        do {
            // 뚜껑 상태 조회
            let lidURL = URL(string: "\(baseURL)/lid/status")!
            let (lidData, _) = try await URLSession.shared.data(from: lidURL)
            
            // 🔍 디버깅: 실제 응답 출력
            if let jsonString = String(data: lidData, encoding: .utf8) {
                print("📦 Lid Status Response: \(jsonString)")
            }
            
            let lidStatus = try JSONDecoder().decode(LidStatus.self, from: lidData)
            
            // 쓰레기통 만차 여부 조회
            let fullnessURL = URL(string: "\(baseURL)/trash/fullness")!
            let (fullnessData, _) = try await URLSession.shared.data(from: fullnessURL)
            
            // 🔍 디버깅: 실제 응답 출력
            if let jsonString = String(data: fullnessData, encoding: .utf8) {
                print("📦 Fullness Status Response: \(jsonString)")
            }
            
            let fullnessStatus = try JSONDecoder().decode(FullnessStatus.self, from: fullnessData)
            
            var timestamp = Date()
            let tsString = fullnessStatus.timestamp
            if let parsedDate = iso8601Formatter.date(from: tsString) {
                timestamp = parsedDate
            }
            
            await MainActor.run {
                self.binStatus = BinStatus(
                    lidOpen: lidStatus.lidOpen,
                    isFull: fullnessStatus.isFull,
                    fullByVolume: fullnessStatus.fullByVolume,
                    fullByWeight: fullnessStatus.fullByWeight,
                    nearFullByVolume: fullnessStatus.nearFullByVolume,
                    distanceCm: fullnessStatus.distanceCm,
                    weightKg: fullnessStatus.weightKg,
                    timestamp: timestamp
                )
                self.isConnected = true
                self.isLoading = false
                self.lastUpdate = Date()
                self.updateLogs()
            }
        } catch {
            await MainActor.run {
                self.isConnected = false
                self.isLoading = false
                print("Failed to fetch data: \(error)")
            }
        }
    }
    
    private func updateLogs() {
        guard let status = binStatus else { return }
        
        // 센서 값 기반으로 적재량 계산
        let maxDistance = 20.0
        let heightPercent = min(100, (status.distanceCm / maxDistance) * 100)
        
        let maxWeight = 6.0
        let weightPercent = min(100, (status.weightKg / maxWeight) * 100)
        
        let fillPercentage = max(heightPercent, weightPercent)
        
        // 로그 생성
        if fillPercentage >= 100 {
            addLog(message: "⚠️ 쓰레기통이 가득 찼습니다!", type: .danger)
        } else if fillPercentage >= 80 {
            addLog(message: "⚡ 쓰레기통이 80% 찼습니다.", type: .warning)
        }
        
        if status.lidOpen {
            addLog(message: "🚪 뚜껑이 열렸습니다.", type: .info)
        }
    }
        
    private func addLog(message: String, type: ActivityLog.LogType) {
        let log = ActivityLog(time: Date(), message: message, type: type)
        logs.insert(log, at: 0)
        if logs.count > 20 {
            logs = Array(logs.prefix(20))
        }
    }
    
    func startAutoRefresh() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchData()
            }
        }
        Task {
            await fetchData()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
