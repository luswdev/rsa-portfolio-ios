//
//  PortfolioAPI.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import Foundation

struct PortfolioAPI {
    struct PortfolioSet {
        let positions: [PositionStruct]
        let histories: [HistoryStruct]
    }
    
    struct TickerInfo: Codable {
        let current: Decimal
        let last: Decimal
    }
    
    struct PortfolioJson: Codable {
        let assert: [PositionJson]
        let portfolio: [HistoryJson]
    }

    struct PositionJson: Codable {
        let color: String
        let cost: Decimal
        let current: Decimal
        let last: Decimal
        let name: String
        let quantity: Decimal
        let ticker: String
        let updated: Bool
    }

    struct HistoryJson: Codable {
        let date: String
        let tw: SubHistoryJson
        let us: SubHistoryJson
    }

    struct SubHistoryJson: Codable {
        let cost: Decimal
        let value: Decimal
    }
    
    let API_BASE = "https://fin.lusw.dev"
    let session = URLSession.shared
    var account = ""
    
    func Login(account: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: self.API_BASE + "/login")!
        let parameters = ["username": account, "password": password]
        let formData = parameters.map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = formData.data(using: .utf8)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(false)
                return
            }
               
            guard let data = data else {
                completion(false)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any],
               let status = dictionary["status"] as? String,
               status == "success" {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    func Logout() {
        let url = URL(string: self.API_BASE + "/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = session.dataTask(with: request)
        task.resume()
    }
    
    func getPortfolio(completion: @escaping (PortfolioSet?) -> Void) {
        let url = URL(string: self.API_BASE + "/config")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil)
                return
            }
               
            guard let data = data else {
                completion(nil)
                return
            }
            
            if let (positions, histories) = portfolioJsonDecoder(jsonString: String(data: data, encoding: .utf8)!) {                
                completion(PortfolioSet(positions: positions, histories: histories))
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func getStock(ticker: String, completion: @escaping (TickerInfo?) -> Void) {
        var trueTicker = ticker
        if ticker.rangeOfCharacter(from: .decimalDigits) != nil {
            trueTicker += ".TW"
        }
        
        let url = URL(string: self.API_BASE + "/stock/" + trueTicker)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil)
                return
            }
               
            guard let data = data else {
                completion(nil)
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
            if let tickerInfo = tickerJsonDecoder(jsonString: String(data: data, encoding: .utf8)!) {
                completion(tickerInfo)
            } else {
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    func getCurrency(ticker: String, completion: @escaping (TickerInfo?) -> Void) {
        var trueTicker = ticker
        if ticker.rangeOfCharacter(from: .decimalDigits) != nil {
            trueTicker += ".TW"
        }
        
        let url = URL(string: self.API_BASE + "/currency/" + trueTicker)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil)
                return
            }
               
            guard let data = data else {
                completion(nil)
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
            if let tickerInfo = tickerJsonDecoder(jsonString: String(data: data, encoding: .utf8)!) {
                completion(tickerInfo)
            } else {
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    func portfolioJsonDecoder(jsonString: String) -> (positions: [PositionStruct], histories: [HistoryStruct])? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let decodedData = try JSONDecoder().decode(PortfolioJson.self, from: jsonData)
            var positionStruct = [PositionStruct]()
            var historyStruct = [HistoryStruct]()
            
            for assert in decodedData.assert {
                positionStruct.append(PositionStruct(ticker: assert.ticker, name: assert.name, quantity: assert.quantity, cost: assert.cost, color: assert.color))
            }
            
            for portfolio in decodedData.portfolio {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM"

                let date = dateFormatter.date(from: portfolio.date)!
                dateFormatter.dateFormat = "MMM yyy"
                
                historyStruct.append(
                    HistoryStruct(date: dateFormatter.string(from: date), usCost: portfolio.us.cost, usBalance: portfolio.us.value, twCost: portfolio.tw.cost, twBalance: portfolio.tw.value)
                )
            }
            
            return (positionStruct, historyStruct)
        } catch {
            return nil
        }
    }

    func tickerJsonDecoder(jsonString: String) -> (TickerInfo)? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let decodedData = try JSONDecoder().decode(TickerInfo.self, from: jsonData)
            return decodedData
        } catch {
            return nil
        }
    }
}
