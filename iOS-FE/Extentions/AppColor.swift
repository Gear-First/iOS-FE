//
//  AppColor.swift
//  iOS-FE
//
//  Created by wj on 10/3/25.
//

import SwiftUI

struct AppColor {
    // Base surfaces
    static let background = Color(hex: "#F4F6FA")
    static let surface = Color(hex: "#FFFFFF")
    static let surfaceMuted = Color(hex: "#F8FAFC")
    static let cardBorder = Color(hex: "#E2E8F0")
    static let cardShadow = Color.black.opacity(0.04)

    // Legacy aliases kept for compatibility
    static let mainWhite = surface        // 기존 명칭 유지
    static let mainBlack = Color(hex: "#111827")
    static let mainTextBlack = Color(hex: "#1F2937")
    static let mainTextGray = Color(hex: "#6B7280")
    static let mainBorderGray = cardBorder
    static let mainBlue = Color(hex: "#2563EB")
    static let mainDarkBlue = Color(hex: "#1D4ED8")
    static let mainRed = Color(hex: "#EF4444")
    static let lightGray = Color(hex: "#D1D5DB")
    static let mainGray = Color(hex: "#94A3B8")
    static let mainYellow = Color(hex: "#F59E0B")
    static let mainGreen = Color(hex: "#10B981")
    static let bgGray = background

    // Accents
    static let accentBlueSoft = Color(hex: "#DBEAFE")
    static let accentSlate = Color(hex: "#334155")
    static let textMuted = Color(hex: "#94A3B8")
}
