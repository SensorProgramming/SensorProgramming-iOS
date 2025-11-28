//
//  StatusCard.swift
//  SensorProgramming-iOS
//
//  Created by 김나연 on 11/28/25.
//

import SwiftUI

struct StatusCard: View {
    let title: String
    let items: [(String, String, Bool)]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ForEach(items.indices, id: \.self) { index in
                    HStack {
                        Text(items[index].0)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(items[index].1)
                            .fontWeight(.bold)
                            .foregroundColor(items[index].2 ? .red : .green)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
