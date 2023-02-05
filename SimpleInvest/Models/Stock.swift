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

