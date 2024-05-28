//
//  RSA_PortfolioApp.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import SwiftUI

//let primaryColor = Color(red:3/256 , green: 105/256, blue: 161/256)

let trendColor: [[Color]] = [
    [.green, .red],
    [.red, .green]
]

@main
struct RSA_PortfolioApp: App {
    var body: some Scene {
        let api: PortfolioAPI = PortfolioAPI()
        WindowGroup {
            ContentView(API: api)
        }
    }
}
