//
//  ExtensionDate.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/27.
//

import Foundation


func str2date(dateString: String) -> Date {
    if dateString == "" {
        return Date.now
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM yyyy"

    let date = dateFormatter.date(from: dateString)!
    return date
}

func date2str(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM yyyy"

    let dateString = dateFormatter.string(from: date)
    return dateString
}
