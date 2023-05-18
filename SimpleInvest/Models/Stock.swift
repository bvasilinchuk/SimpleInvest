//
//  File.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import Foundation
import SwiftUI

//Stock object that has all the information and is widely used throughout the app
struct Stock: Identifiable, Equatable{
    var id = UUID()
    var firebaseId = ""
    var currentPrice: Double?
    var quantity: Int
    let name: String
    let ticker: String
    var marketCap: Double?
    var peRatio: String?
    var dividendsPastYear: Double?
    var divRatePastYearText: String?
    var dividendYield: Double?
    var fiftyTwoWeekHigh: Double?
    var fiftyTwoWeekLow: Double?
    var averagePrice: Double
    var marketCapText: String?
    var epsText: String?
    var beta: String?
    var priceToBook: String?
    var dividendDate: Date?
    var averageProfitCash: Double?{
        if let currentPrice {
            return (currentPrice - averagePrice) * Double(quantity)
        } else {return 0}
    }
    var averageProfitPercent: Double?{
        if let currentPrice {
            return abs(((currentPrice/averagePrice) * 100) - 100)
        } else {return 0}
    }
    var totalPrice: Double?{
        if let currentPrice {
            return Double(quantity) * currentPrice
        } else {return 0}
    }
}


extension Stock{
    static var previewStocks: [Stock] = [Stock(currentPrice: 174.5, quantity: 2, name: "Apple", ticker: "AAPL", marketCap: 2350000, peRatio: "5", dividendsPastYear: 4, dividendYield: 0.03, fiftyTwoWeekHigh: 190, fiftyTwoWeekLow: 140, averagePrice: 160, marketCapText: "100M", epsText: "1"), Stock(currentPrice: 112, quantity: 1, name: "Google", ticker: "GOOGL", marketCap: 1190000, peRatio: "6", dividendsPastYear: 5, dividendYield: 0, fiftyTwoWeekHigh: 123, fiftyTwoWeekLow: 80, averagePrice: 120, marketCapText: "200M", epsText: "2")]
    
    var currentPriceText: String {
        Utils.format(value: currentPrice) ?? "-"
    }
    
    var quantityText: String {
        String(quantity)
    }
    
}
