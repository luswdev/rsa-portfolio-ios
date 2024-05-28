//
//  History.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/28.
//

import Foundation

struct HistoryStruct: Identifiable, Equatable {
    let id = UUID()

    struct SubHistory: Identifiable, Equatable {
        let id = UUID()

        var cost: Decimal
        var balance: Decimal
        var currency: CurrencyBase
        
        init(cost: Decimal, balance: Decimal, currency: CurrencyBase) {
            self.cost = cost
            self.balance = balance
            self.currency = currency
        }
        
        static func == (lhs: SubHistory, rhs: SubHistory) -> Bool {
            if lhs.cost != rhs.cost {
                return false
            }
            
            if lhs.balance != rhs.balance {
                return false
            }
            
            return true
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

        func getBalance(selectedCurrency: CurrencyBase, twdusd: Decimal) -> Decimal {
            if selectedCurrency == currency {
                return balance
            } else {
                if (selectedCurrency == CurrencyBase.twd) {
                    return balance * twdusd
                } else {
                    return balance / twdusd
                }
            }
        }
    }
    
    var date: String
    var us: SubHistory
    var tw: SubHistory

    init(date: String, usCost: Decimal, usBalance: Decimal, twCost: Decimal , twBalance: Decimal){
        self.date = date
        self.us = SubHistory(cost: usCost, balance: usBalance, currency: CurrencyBase.usd)
        self.tw = SubHistory(cost: twCost, balance: twBalance, currency: CurrencyBase.twd)
    }
    
    static func == (lhs: HistoryStruct, rhs: HistoryStruct) -> Bool {
        if lhs.date != rhs.date {
            return false
        }
        
        if lhs.tw != rhs.tw {
            return false
        }
        
        if lhs.us != rhs.us {
            return false
        }
        
        return true
    }
}
