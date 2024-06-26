//
//  ExtensionColor.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/26.
//

import Foundation
import SwiftUI

let trendColor: [[Color]] = [
    [.green, .red],
    [.red, .green]
]

func hex2color(hex: String) -> Color? {
    let r, g, b: CGFloat

    if hex.hasPrefix("#") {
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                return Color(red: r, green: g, blue: b)
            }
        }
    }

    return nil
}

func color2hex(color: Color) -> String {
    @Environment(\.self) var environment

    var components: Color.Resolved?
    components = color.resolve(in: environment)

    var hexString = "#"
    if let components {
        let red = max(0.0, min(components.red, 1.0))
        let green = max(0.0, min(components.green, 1.0))
        let blue = max(0.0, min(components.blue, 1.0))
        
        hexString += String(format: "%02X", Int(red * 255))
        hexString += String(format: "%02X", Int(green * 255))
        hexString += String(format: "%02X", Int(blue * 255))
    } else {
        hexString += "0369A1"
    }
    
    return hexString
}

func trendColor(trend: Bool , trendStyle: Bool) -> Color {
    let trendRaise: Color = trendColor[trendStyle ? 1 : 0][0]
    let trendFall:  Color = trendColor[trendStyle ? 1 : 0][1]
    if (trend) {
        return trendRaise
    } else {
        return trendFall
    }
}
