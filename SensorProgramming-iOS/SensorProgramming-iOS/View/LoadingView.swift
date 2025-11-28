//
//  LoadingView.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 50))
                .foregroundColor(.indigo)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
                .onAppear {
                    isRotating = true
                }
            
            Text("로딩 중...")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}
