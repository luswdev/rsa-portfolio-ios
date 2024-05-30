//
//  StockEditerView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/26.
//

import Foundation
import SwiftUI

struct StockEditorView: View {
    @Binding private var position: PositionStruct
    @Binding private var editSuccess: Bool
    @State private var holdColor: Color
    
    @State private var showAlert = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Symbol")
                            .frame(width: 75, alignment: .leading)
                        TextField("QQQ", text: $position.ticker)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Name")
                            .frame(width: 75, alignment: .leading)
                        TextField("Invesco QQQ Trust", text: $position.name)
                            .autocapitalization(.none)
                    }
                }
                Section {
                    HStack {
                        Text("Quantity")
                            .frame(width: 75, alignment: .leading)
                        TextField("0", value: $position.quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Cost")
                            .frame(width: 75, alignment: .leading)
                        TextField("0", value: $position.cost, format: .number)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }
                }
                Section {
                    ColorPicker("Stock Color", selection: $holdColor)
                }
                Section {
                    Button(
                        action: {
                            if position.ticker == "" || position.name == "" || position.quantity == 0 || position.cost == 0 {
                                showAlert = true
                                return
                            }
                            
                            position.color = color2hex(color: holdColor)
                            
                            editSuccess = true
                            presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            Text("Save Hold")
                                .foregroundColor(Color("Main"))
                                .frame(maxWidth: .infinity)
                        }
                    )
                }
            }
            .padding(.vertical)
            .navigationTitle("New Hold")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Hold Information Incorrect"),
                message: Text("Please filled in all information."),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    init(
        position: Binding<PositionStruct>,
        editSuccess: Binding<Bool>
    ) {
        self._position = position
        self.holdColor = hex2color(hex: position.wrappedValue.color) ?? Color("Main")
        self._editSuccess = editSuccess
    }
}

#Preview {
    StockEditorView(
        position: .constant(PositionStruct(ticker: "", name: "", quantity: 0.66656, cost: 300, color: "#5E35B1")),
        editSuccess: .constant(false)
    )
}
