//
//  ExtensionColor.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/26.
//

import Foundation
import SwiftUI

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
        hexString += String(format: "%02hhX", components.red * 256)
        hexString += String(format: "%02hhX", components.green * 256)
        hexString += String(format: "%02hhX", components.blue * 256)
    } else {
        hexString += "0369A1"
    }
    
    return hexString
}
