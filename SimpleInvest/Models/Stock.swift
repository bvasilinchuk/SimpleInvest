//
//  File.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import Foundation

//Stock object that has all the information and is widely used throughout the app
struct Stock: Identifiable, Decodable, Equatable{
    var id = UUID()
    var firebaseId = ""
    var currentPrice: Double
    var quantity: Double
    let name: String
    let ticker: String
    let description: String
    let currency: String
    let marketCap: Double
//    let ebitda: Double
    let peRatio: Double
    let dividendsPastYear: Double
    let dividendYield: Double
    let fiftyTwoWeekHigh: Double
    let fiftyTwoWeekLow: Double
    var averagePrice: Double
    var marketCapText: String
    var averageProfitCash: Double{
        (currentPrice - averagePrice) * Double(quantity)
    }
    var averageProfitPercent: Double{
        abs(((currentPrice/averagePrice) * 100) - 100)
    }
    var totalPrice: Double{
        Double(quantity) * currentPrice
    }
}


extension Stock{
    static var previewStocks: [Stock] = [Stock(currentPrice: 174.5, quantity: 2, name: "Apple", ticker: "AAPL", description: "Test description", currency: "USD", marketCap: 2350000, peRatio: 12.5, dividendsPastYear: 3.4, dividendYield: 0.03, fiftyTwoWeekHigh: 190, fiftyTwoWeekLow: 140, averagePrice: 160, marketCapText: "100M"), Stock(currentPrice: 112, quantity: 1, name: "Google", ticker: "GOOGL", description: "Google description", currency: "USD", marketCap: 1190000, peRatio: 22, dividendsPastYear: 0, dividendYield: 0, fiftyTwoWeekHigh: 123, fiftyTwoWeekLow: 80, averagePrice: 120, marketCapText: "200M")]
    
}
