//
//  PositionStruct.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/28.
//

import Foundation

struct PositionStruct: Identifiable {
    let id = UUID()
    
    var color: String
    var ticker: String
    var name: String
    var current: Decimal
    var last: Decimal
    var quantity: Decimal
    var cost: Decimal
    var currency: CurrencyBase
    
    init(ticker: String, name: String, quantity: Decimal, cost: Decimal, color: String){
        self.ticker = ticker
        self.name = name
        self.quantity = quantity
        self.cost = cost
        self.color = color
        self.current = 457.95
        self.last =  455.71
        
        if ticker.rangeOfCharacter(from: .decimalDigits) != nil {
            self.currency = CurrencyBase.twd
        } else {
            self.currency = CurrencyBase.usd
        }
    }
    
    func getCost(selectedCurrency: CurrencyBase, twdusd: Decimal) -> Decimal {
        if selectedCurrency == currency {
            return cost
        } else {
            if (selectedCurrency == CurrencyBase.twd) {
                return cost * twdusd
            } else {
                return cost / twdusd
            }
        }
    }

    func getValue(selectedCurrency: CurrencyBase, twdusd: Decimal) -> Decimal {
        if selectedCurrency == currency {
            return current * quantity
        } else {
            if (selectedCurrency == CurrencyBase.twd) {
                return current * quantity * twdusd
            } else {
                return current * quantity / twdusd
            }
        }
    }
}
