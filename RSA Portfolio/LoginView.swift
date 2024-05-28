//
//  LoginView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import Foundation
import SwiftUI
import LocalAuthentication

struct LoginView: View {
    var API: PortfolioAPI

    @Binding var isNeedLogin: Bool
    @Binding var faceIdEn: Bool
    @Binding var loginAccount: String
    @Binding var loginPassword: String
    @Binding var positions: [PositionStruct]
    @Binding var histories: [HistoryStruct]
    @Binding var twdusd: Decimal
    
    @State private var saveInfo = UserDefaults.standard.bool(forKey: "saveLogin")
    
    @State private var showAlert = false

    @State private var account: String = (UserDefaults.standard.string(forKey: "loginAccount") ?? "")
    @State private var password: String = (UserDefaults.standard.string(forKey: "loginPassword") ?? "")

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .frame(width: 65, height: 65)
                .scaledToFill()
                .cornerRadius(10)

            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("Account")) {
                            TextField("Account", text: $account)
                                .textContentType(.username)
                                .autocapitalization(.none)
                        }
                        Section(header: Text("Password")) {
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                            
                            Toggle(isOn: $saveInfo) {
                                Text("Save Account and Password")
                            }.onChange(of: saveInfo) {
                                UserDefaults.standard.set(saveInfo, forKey: "saveLogin")
                            }
                        }
                        Button(
                            action: {
                                doLogin()
                            },
                            label: {
                                Text("Login")
                                    .foregroundColor(Color("Main"))
                                    .frame(maxWidth: .infinity)
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .navigationTitle("RSA Portfolio")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear(perform: authenticate)
        .alert("Login Failed", isPresented: $showAlert) {
       
        } message: {
            Text("Please check your account or password first")
        }
    }
    
    init(
        isNeedLogin: Binding<Bool>,
        faceIdEn: Binding<Bool>,
        loginAccount: Binding<String>,
        loginPassword: Binding<String>,
        positions: Binding<[PositionStruct]>,
        histories: Binding<[HistoryStruct]>,
        twdusd: Binding<Decimal>,
        API: PortfolioAPI = PortfolioAPI()
    ){
        self.API = API
        self._isNeedLogin = isNeedLogin
        self._faceIdEn = isNeedLogin
        self._loginAccount = loginAccount
        self._loginPassword = loginPassword
        self._positions = positions
        self._histories = histories
        self._twdusd = twdusd
    }
    
    func doLogin() {
        API.Login(account: account, password: password) { success in
            if success {
                DispatchQueue.main.async {
                    isNeedLogin = false
                    loginAccount = account
                    loginPassword = password
                    API.getPortfolio() { portfolio in
                        guard portfolio != nil else {
                            isNeedLogin = true
                            showAlert = true
                            return
                        }
                        
                        positions = portfolio!.positions
                        histories = portfolio!.histories
                        
                        for index in positions.indices {
                            API.getStock(ticker: positions[index].ticker) { info in
                                guard info != nil else {
                                    isNeedLogin = true
                                    showAlert = true
                                    return
                                }
                                
                                positions[index].current = info!.current
                                positions[index].last = info!.last
                            }
                        }
                        
                        API.getCurrency(ticker: "TWD") { info in
                            guard info != nil else {
                                isNeedLogin = true
                                showAlert = true
                                return
                            }
                            
                            twdusd = info!.current
                        }
                    }

                    if saveInfo {                                            
                        UserDefaults.standard.set(account, forKey: "loginAccount")
                        UserDefaults.standard.set(password, forKey: "loginPassword")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "loginAccount")
                        UserDefaults.standard.removeObject(forKey: "loginPassword")
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                showAlert = true
                account = ""
                password = ""
            }
        }
    }
    
    func authenticate() {
        if !faceIdEn {
            return
        }
        
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Use Face ID to login."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    account = (UserDefaults.standard.string(forKey: "LAloginAccount") ?? "")
                    password = (UserDefaults.standard.string(forKey: "LAloginPassword") ?? "")
                    doLogin()
                    return
                } else {
                    // auth failed, do nothings
                    return
                }
            }
        } else {
            // no biometrics, do nothings
        }
    }
}

#Preview {
    LoginView(
        isNeedLogin: .constant(false),
        faceIdEn: .constant(false),
        loginAccount: .constant(""),
        loginPassword: .constant(""),
        positions: .constant([PositionStruct]()),
        histories: .constant([HistoryStruct]()),
        twdusd: .constant(30)
    )
}
