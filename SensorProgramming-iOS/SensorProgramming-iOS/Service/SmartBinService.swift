//
//  SmartBinService.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI
import AVFoundation

class SmartBinService: ObservableObject {
    @Published var binStatus: BinStatus?
    @Published var logs: [ActivityLog] = []
    @Published var isConnected = true
    @Published var isLoading = true
    @Published var lastUpdate: Date?
    
    private let baseURL = "http://15.165.212.56:8000"
    private var timer: Timer?
    
    // 오디오 플레이어
    private var audioPlayer: AVAudioPlayer?
    
    // 이전 뚜껑 상태 추적 (상태 변화 감지용)
    private var previousLidOpen: Bool?
    
    // ISO8601 날짜 파서
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    init() {
        // 오디오 세션 설정
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ 오디오 세션 활성화 성공")
        } catch {
            print("❌ 오디오 세션 설정 실패: \(error.localizedDescription)")
        }
        
        startAutoRefresh()
    }
    
    func fetchData() async {
        do {
            // 뚜껑 상태 조회
            let lidURL = URL(string: "\(baseURL)/lid/status")!
            let (lidData, lidResponse) = try await URLSession.shared.data(from: lidURL)
            
            // 🔍 디버깅: 실제 응답 출력
            if let jsonString = String(data: lidData, encoding: .utf8) {
                print("📦 Lid Status Response: \(jsonString)")
            }
            
            // HTTP 상태 코드 확인
            if let httpResponse = lidResponse as? HTTPURLResponse {
                print("🌐 Lid Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    throw NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Lid API returned status code \(httpResponse.statusCode)"
                    ])
                }
            }
            
            let lidStatus = try JSONDecoder().decode(LidStatus.self, from: lidData)
            
            // 쓰레기통 만차 여부 조회
            let fullnessURL = URL(string: "\(baseURL)/trash/fullness")!
            let (fullnessData, fullnessResponse) = try await URLSession.shared.data(from: fullnessURL)
            
            // 🔍 디버깅: 실제 응답 출력
            if let jsonString = String(data: fullnessData, encoding: .utf8) {
                print("📦 Fullness Status Response: \(jsonString)")
            }
            
            // HTTP 상태 코드 확인
            if let httpResponse = fullnessResponse as? HTTPURLResponse {
                print("🌐 Fullness Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    throw NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Fullness API returned status code \(httpResponse.statusCode)"
                    ])
                }
            }
            
            let fullnessStatus = try JSONDecoder().decode(FullnessStatus.self, from: fullnessData)
            
            // 타임스탬프 파싱
            var timestamp = Date()
            let tsString = fullnessStatus.timestamp
            if let parsedDate = iso8601Formatter.date(from: tsString) {
                timestamp = parsedDate
            }
            
            await MainActor.run {
                // 🔍 디버깅: 실제 파싱된 값 확인
                print("=== Parsed Values ===")
                print("lidOpen: \(lidStatus.lidOpen ?? false)")
                print("isFull: \(fullnessStatus.isFull ?? false)")
                print("fullByVolume: \(fullnessStatus.fullByVolume ?? false)")
                print("fullByWeight: \(fullnessStatus.fullByWeight ?? false)")
                print("nearFullByVolume: \(fullnessStatus.nearFullByVolume ?? false)")
                print("distanceCm: \(fullnessStatus.distanceCm ?? 0.0)")
                print("weightKg: \(fullnessStatus.weightKg ?? 0.0)")
                print("==================")
                
                self.binStatus = BinStatus(
                    lidOpen: lidStatus.lidOpen ?? false,
                    isFull: fullnessStatus.isFull ?? false,
                    fullByVolume: fullnessStatus.fullByVolume ?? false,
                    fullByWeight: fullnessStatus.fullByWeight ?? false,
                    nearFullByVolume: fullnessStatus.nearFullByVolume ?? false,
                    distanceCm: fullnessStatus.distanceCm ?? 0.0,
                    weightKg: fullnessStatus.weightKg ?? 0.0,
                    timestamp: timestamp
                )
                self.isConnected = true
                self.isLoading = false
                self.lastUpdate = Date()
                self.updateLogs()
                
                // 뚜껑 상태 변화 체크 및 음성 재생
                self.checkLidStatusChange()
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
    
    // 음성 재생 함수
    private func playSound(named soundName: String) {
        print("🎵 playSound 호출됨: \(soundName)")
        
        // Bundle에서 파일 찾기
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("❌ 사운드 파일을 찾을 수 없습니다: \(soundName).mp3")
            print("📁 Bundle 경로: \(Bundle.main.bundlePath)")
            
            // Bundle의 모든 리소스 출력 (디버깅용)
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    print("📂 Bundle 내용물: \(contents.filter { $0.hasSuffix(".mp3") })")
                } catch {
                    print("❌ Bundle 내용물 읽기 실패")
                }
            }
            return
        }
        
        print("✅ 파일 찾음: \(soundURL.path)")
        
        do {
            // 오디오 플레이어 생성
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            
            let success = audioPlayer?.play() ?? false
            if success {
                print("🔊 음성 재생 시작: \(soundName).mp3")
                print("⏱️ 재생 시간: \(audioPlayer?.duration ?? 0)초")
            } else {
                print("❌ 재생 실패 (play() returned false)")
            }
        } catch {
            print("❌ 음성 재생 실패: \(error.localizedDescription)")
        }
    }
    
    // 뚜껑 상태 변화 감지 및 음성 재생
    private func checkLidStatusChange() {
        guard let currentStatus = binStatus else {
            print("⚠️ binStatus가 nil입니다")
            return
        }
        
        print("🔍 현재 뚜껑 상태: \(currentStatus.lidOpen ? "열림" : "닫힘")")
        
        // 이전 상태가 없으면 (첫 실행) 현재 상태만 저장
        guard let previous = previousLidOpen else {
            print("🆕 첫 실행 - 이전 상태 저장")
            previousLidOpen = currentStatus.lidOpen
            return
        }
        
        print("🔄 이전: \(previous ? "열림" : "닫힘") → 현재: \(currentStatus.lidOpen ? "열림" : "닫힘")")
        
        // 상태 변화 감지
        if previous != currentStatus.lidOpen {
            print("✨ 상태 변화 감지!")
            
            if currentStatus.lidOpen {
                // 열림: jubguengamji.mp3 재생
                print("🚪 뚜껑 열림 감지 → 접근감지 음성 재생")
                playSound(named: "jubguengamji")
            } else {
                // 닫힘: ddathim.mp3 재생
                print("🚪 뚜껑 닫힘 감지 → 닫힘 음성 재생")
                playSound(named: "ddathim")
            }
            
            // 현재 상태를 이전 상태로 업데이트
            previousLidOpen = currentStatus.lidOpen
        } else {
            print("➡️ 상태 변화 없음")
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
