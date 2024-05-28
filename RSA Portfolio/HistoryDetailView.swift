//
//  HistoryDetailView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/26.
//

import Foundation
import SwiftUI

struct HistoryDetailView: View {
    var twdusd: Decimal
    var history: HistoryStruct
    var historyIndex: Int
    
    @State private var showEdit = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Taiwan")) {
                    HStack {
                        Text("Cost")
                        Spacer()
                        Text(history.tw.cost, format: Decimal.FormatStyle.Currency(code: "TWD"))
                    }
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text(history.tw.balance, format: Decimal.FormatStyle.Currency(code: "TWD"))
                    }
                    HStack {
                        Text("CAGR")
                        Spacer()
                        Text("\(calcCAGR(idx: historyIndex, balance: history.tw.balance, cost: history.tw.cost), specifier: "%.2f")%")
                    }
                }
                Section(header: Text("United State")) {
                    HStack {
                        Text("Cost")
                        Spacer()
                        Text(history.us.cost, format: Decimal.FormatStyle.Currency(code: "TWD"))
                    }
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text(history.us.balance, format: Decimal.FormatStyle.Currency(code: "TWD"))
                    }
                    HStack {
                        Text("CAGR")
                        Spacer()
                        Text("\(calcCAGR(idx: historyIndex, balance: history.us.balance, cost: history.us.cost), specifier: "%.2f")%")
                    }
                }
                Section(header: Text("Taiwan")) {
                    HStack {
                        Text("Cost")
                        Spacer()
                        Text(history.tw.cost + history.us.cost * twdusd,
                             format: Decimal.FormatStyle.Currency(code: "TWD"))
                    }
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text(history.tw.balance + history.us.balance * twdusd,
                             format: Decimal.FormatStyle.Currency(code: "TWD"))
                    }
                    HStack {
                        Text("CAGR")
                        Spacer()
                        Text("\(calcCAGR(idx: historyIndex, balance: history.tw.balance + history.us.balance * twdusd, cost: history.tw.cost + history.us.cost * twdusd), specifier: "%.2f")%")
                    }
                }
            }
            .toolbar {
                Button {
                   showEdit = true
               } label: {
                   HStack {
                       Image(systemName: "pencil")
                           .foregroundStyle(Color("Main"))
                       Text("Edit Record")
                           .font(.system(.body, design: .rounded).bold())
                           .foregroundStyle(Color("Main"))
                   }
               }
               .buttonStyle(.plain)
            }
            .navigationTitle(history.date)
        }
        .sheet(isPresented: $showEdit) {
            HistoryEditerView(history: history)
        }
    }

    init(
        twdusd: Decimal,
        history: HistoryStruct,
        historyIndex: Int
    ) {
        self.twdusd = twdusd
        self.history = history
        self.historyIndex = historyIndex
    }
    
    
    func calcCAGR (idx: Int, balance: Decimal, cost: Decimal) -> Float {
        let gainLoss = balance - cost
        let totalMonth = idx + 1
        let returns = (gainLoss / cost) + 1
        let CAG = pow(returns, (12 / totalMonth)) - 1
        let CAGR: Float = Float(truncating: CAG * 100 as NSNumber)
        
        return CAGR
    }
}

#Preview {
    HistoryDetailView(
        twdusd: 30,
        history: HistoryStruct(date: "May 2024", usCost: 900, usBalance: 904.86, twCost: 43381, twBalance: 43880.00),
        historyIndex: 1
    )
}


