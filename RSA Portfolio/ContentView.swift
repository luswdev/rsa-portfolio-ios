//
//  ContentView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import SwiftUI

enum CurrencyBase: String, CaseIterable, Identifiable {
    case usd = "USD"
    case twd = "TWD"
    var id: Self { self }
}


struct ContentView: View {
    var API: PortfolioAPI
    
    @State private var isNeedLogin: Bool = true
    @State private var faceIdEn: Bool = UserDefaults.standard.bool(forKey: "LAen")
    @State var loginAccount: String
    @State var loginPassword: String
    @State private var positions: [PositionStruct]
    @State private var histories: [HistoryStruct]
    @State private var twdusd: Decimal
    @State private var trendStyle: Bool = UserDefaults.standard.bool(forKey: "TrendStyle")
    @State private var selectedCurrency: CurrencyBase = (CurrencyBase(rawValue: UserDefaults.standard.string(forKey: "SelectedCurrency") ?? "TWD") ?? CurrencyBase.twd)
    
    @State private var needUpload: Bool = false

    var body: some View {
        TabView {
            PositionTabView(
                positions: $positions,
                twdusd: $twdusd,
                selectedCurrency: $selectedCurrency,
                trendStyle: $trendStyle,
                API: API
            ).tabItem {
                Label("Positions", systemImage: "tray.full.fill")
            }

            HistoryTabView(
                histories: $histories,
                twdusd: $twdusd,
                selectedCurrency: $selectedCurrency,
                needUpload: $needUpload
            ).tabItem {
                Label("Histories", systemImage: "clock")
            }

            SettingTabView(
                isNeedLogin: $isNeedLogin,
                faceIdEn: $faceIdEn,
                loginAccount: $loginAccount,
                loginPassword: $loginPassword,
                trendStyle: $trendStyle,
                selectedCurrency: $selectedCurrency
            ).tabItem {
                Label("Setting", systemImage: "gear")
            }
        }
        .onChange(of: needUpload) {
            if needUpload {
                API.uploadPortfolio(
                    portfolio: PortfolioAPI.PortfolioSet(positions: positions, histories: histories)
                ) { success in
                    needUpload = false
                }
            }
        }
        .accentColor(Color("Main"))
        .fullScreenCover(isPresented: self.$isNeedLogin) {
            LoginTabView(
                isNeedLogin: $isNeedLogin,
                faceIdEn: $faceIdEn,
                loginAccount: $loginAccount,
                loginPassword: $loginPassword,
                positions: $positions,
                histories: $histories,
                twdusd: $twdusd,
                API: API
            )
        }
    }
    
    init(API: PortfolioAPI = PortfolioAPI()) {
        self.API = API
        self.positions = [PositionStruct]()
        self.histories = [HistoryStruct]()
        self.twdusd = 30
        self.loginAccount = ""
        self.loginPassword = ""
    }
}

#Preview {
    ContentView()
}
