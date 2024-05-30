//
//  HistoryEditerView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/27.
//

import Foundation
import SwiftUI

struct HistoryEditorView: View {
    @Binding private var history: HistoryStruct
    @Binding private var editSuccess: Bool
    @State private var historyDate: Date
    
    @State private var showAlert = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        DatePicker("Record Month", selection: $historyDate, displayedComponents: [.date])
                    }
                }
                Section(header: Text("Taiwan")) {
                    HStack {
                        Text("Cost")
                            .frame(width: 75, alignment: .leading)
                        TextField("0", value: $history.tw.cost, format: .number)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Balance")
                            .frame(width: 75, alignment: .leading)
                        TextField("0", value: $history.tw.balance, format: .number)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }
                }
                Section(header: Text("United State")) {
                    HStack {
                        Text("Cost")
                            .frame(width: 75, alignment: .leading)
                        TextField("0", value: $history.us.cost, format: .number)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Balance")
                            .frame(width: 75, alignment: .leading)
                        TextField("0", value: $history.us.balance, format: .number)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }
                }
                Section {
                    Button(
                        action: {
                            history.date = date2str(date: historyDate)
                            
                            if history.date == "" || history.tw.cost == 0 || history.tw.balance == 0 || history.us.cost == 0 || history.us.balance == 0 {
                                showAlert = true
                                return
                            }
                            
                            editSuccess = true
                            presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            Text("Save Record")
                                .foregroundColor(Color("Main"))
                                .frame(maxWidth: .infinity)
                        }
                    )
                }
            }
            .padding(.vertical)
            .navigationTitle("New Record")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Record Information Incorrect"),
                message: Text("Please filled in all information."),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    init(
        history: Binding<HistoryStruct>,
        editSuccess: Binding<Bool>
    ) {
        self._history = history
        self.historyDate = str2date(dateString: history.date.wrappedValue)
        self._editSuccess = editSuccess
    }
}

#Preview {
    HistoryEditorView(
        history: .constant(
                    HistoryStruct(date: "May 2024", usCost: 900, usBalance: 904.86, twCost: 43381, twBalance: 43880.00)
                ),
        editSuccess: .constant(false)
    )
}
