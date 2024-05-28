//
//  StockDetailView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/26.
//

import Foundation
import SwiftUI

struct StockDetailView: View {
    var position: PositionStruct
    
    var returns: Float {
        Float(truncating: ((position.current * position.quantity - position.cost) / position.cost) as NSNumber)
    }
    
    @Binding private var trendStyle: Bool

    @State private var showEdit = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(position.name)
                            .foregroundColor(.secondary)

                    }
                    HStack {
                        Text("Symbol")
                        Spacer()
                        Text(position.ticker)
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("Price")) {
                    HStack {
                        Text("Last")
                        Spacer()
                        Text(position.current, format: Decimal.FormatStyle.Currency(code: position.currency.rawValue))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Change")
                        Spacer()
                        Text(position.current - position.last, format: Decimal.FormatStyle.Currency(code: position.currency.rawValue))
                            .foregroundColor(trendColor(trend: position.current >= position.last, trendStyle: trendStyle))
                    }
                }
                Section(header: Text("Holds")) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(position.quantity)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Cost")
                        Spacer()
                        Text(position.cost, format: Decimal.FormatStyle.Currency(code: position.currency.rawValue))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Value")
                        Spacer()
                        Text(position.current * position.quantity, format: Decimal.FormatStyle.Currency(code: position.currency.rawValue))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Gain/Loss")
                        Spacer()
                        Text(position.current * position.quantity - position.cost, format: Decimal.FormatStyle.Currency(code: position.currency.rawValue))
                            .foregroundColor(
                                trendColor(
                                    trend: position.current * position.quantity >= position.cost,
                                    trendStyle: trendStyle
                                )
                            )
                    }
                    HStack {
                        Text("Return")
                        Spacer()
                        Text("\(returns * 100, specifier: "%.2f")%")
                            .foregroundColor(
                                trendColor(
                                    trend: position.current * position.quantity >= position.cost,
                                    trendStyle: trendStyle
                                )
                            )
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
                       Text("Edit Hold")
                           .font(.system(.body, design: .rounded).bold())
                           .foregroundStyle(Color("Main"))
                   }
               }
               .buttonStyle(.plain)
            }
            .navigationTitle(position.name)
        }
        .sheet(isPresented: $showEdit) {
            StockEditorView(position: position)
        }
    }

    init(
        position: PositionStruct,
        trendStyle: Binding<Bool>
    ) {
        self.position = position
        self._trendStyle = trendStyle
    }
}

#Preview {
    StockDetailView(
        position: PositionStruct(ticker: "QQQ", name: "Invesco QQQ Trust", quantity: 0.66656, cost: 300, color: "#26a69a"),
        trendStyle: .constant(false)
    )
}
