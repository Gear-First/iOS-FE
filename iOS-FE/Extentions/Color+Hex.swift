//
//  Color+Hex.swift
//  iOS-FE
//
//  Created by wj on 10/3/25.
//

import SwiftUI

extension Color {
    /// Hex 코드로 Color 생성, opacity 기본값 1.0
    init(hex: String, opacity: Double = 1.0) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // # 제거
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
}
