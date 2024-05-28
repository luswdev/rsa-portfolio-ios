//
//  SettingView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import Foundation
import SwiftUI

struct SettingView: View {
    var API: PortfolioAPI
    
    @Binding private var isNeedLogin: Bool
    @Binding private var faceIdEn: Bool
    @Binding var loginAccount: String
    @Binding var loginPassword: String
    @Binding private var trendStyle: Bool
    
    @Binding var selectedCurrency: CurrencyBase
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Visual")) {
                    Toggle(isOn: $trendStyle) {
                        Text("Taiwan Trend Style")
                    }.onChange(of: trendStyle) {
                        UserDefaults.standard.set(trendStyle, forKey: "TrendStyle")
                    }

                    Picker("Currency", selection: $selectedCurrency) {
                        Text("USD").tag(CurrencyBase.usd)
                        Text("TWD").tag(CurrencyBase.twd)
                    }
                    .onChange(of: selectedCurrency) {
                        UserDefaults.standard.set(selectedCurrency.rawValue, forKey: "SelectedCurrency")
                    }
                }

                Section(header: Text("Account")) {
                    HStack {
                        Text("User Name")
                        Spacer()
                        Text(loginAccount)
                            .foregroundColor(.secondary)
                    }
                    Toggle(isOn: $faceIdEn) {
                        Text("Face ID")
                    }.onChange(of: faceIdEn) {
                        
                        UserDefaults.standard.set(faceIdEn, forKey: "LAen")
                        UserDefaults.standard.set(loginAccount, forKey: "LAloginAccount")
                        UserDefaults.standard.set(loginPassword, forKey: "LAloginPassword")
                    }
                }
                
                Section(header: Text("Others")) {
                    HStack {
                        Text("Application Version")
                        Spacer()
                        Text(appVersion!)
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button(
                        action: {
                            API.Logout()
                            isNeedLogin = true
                        },
                        label: {
                            Text("Logout")
                        }
                    )
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Setting")
        }
    }

    init(
        API: PortfolioAPI = PortfolioAPI(),
        isNeedLogin: Binding<Bool>,
        faceIdEn: Binding<Bool>,
        loginAccount: Binding<String>,
        loginPassword: Binding<String>,
        trendStyle: Binding<Bool>,
        selectedCurrency: Binding<CurrencyBase>
    ) {
        self.API = API
        self._isNeedLogin = isNeedLogin
        self._faceIdEn = faceIdEn
        self._loginAccount = loginAccount
        self._loginPassword = loginPassword
        self._trendStyle = trendStyle
        self._selectedCurrency = selectedCurrency
    }
}

#Preview {
    SettingView(
        isNeedLogin: .constant(false),
        faceIdEn: .constant(false),
        loginAccount: .constant(""),
        loginPassword: .constant(""),
        trendStyle: .constant(false),
        selectedCurrency: .constant(CurrencyBase.twd)
    )
}

