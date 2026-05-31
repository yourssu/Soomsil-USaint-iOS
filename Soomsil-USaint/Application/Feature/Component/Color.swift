//
//  Color.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import SwiftUI

extension Color {
    static let adaptiveBackground = adaptive(light: .white, dark: assetColor("gray_950"))
    static let adaptiveSurface = adaptive(light: .white, dark: assetColor("gray_900"))
    static let adaptiveMutedSurface = adaptive(light: assetColor("gray_25"), dark: assetColor("gray_800").withAlphaComponent(0.36))
    static let adaptiveInputSurface = adaptive(light: .white, dark: assetColor("gray_800").withAlphaComponent(0.52))
    static let adaptiveBorder = adaptive(light: assetColor("slate_100"), dark: assetColor("gray_800").withAlphaComponent(0.45))
    static let adaptivePrimaryText = adaptive(light: assetColor("gray_950"), dark: .white)
    static let adaptiveSecondaryText = adaptive(light: assetColor("gray_500"), dark: assetColor("gray_500"))
    static let adaptiveTertiaryText = adaptive(light: assetColor("slate_500"), dark: assetColor("slate_500"))
    static let adaptiveSelectedPill = adaptive(light: assetColor("gray_950"), dark: assetColor("blue_600"))

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }

    private static func assetColor(_ name: String) -> UIColor {
        UIColor(named: name) ?? .clear
    }
}
