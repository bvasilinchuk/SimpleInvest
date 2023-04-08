//
//  StockFromAPI.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 12.03.2023.
//

import Foundation

//StockQuote from https://query1.finance.yahoo.com/v7/finance/quote?symbols=AAPL

struct StockQuoteYahoo: Codable {
    let regularMarketPrice: Double?
    let longName: String?
    let financialCurrency: String?
    let marketCap: Double?
    let trailingPE: Double?
    let forwardPE: Double?
    let trailingAnnualDividendRate: Double?
    let trailingAnnualDividendYield: Double?
    let fiftyTwoWeekLow: Double?
    let fiftyTwoWeekHigh: Double?
}

struct StockQuoteYahooResponse: Decodable {
    let data: [StockQuoteYahoo]?
    let error: ErrorResponse?
    
    enum CodingKeys: CodingKey{
        case quoteResponse
        case finance
    }
    
    enum ResponseKeys: CodingKey{
        case result
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let quoteResponseContainer = try? container.nestedContainer(keyedBy: ResponseKeys.self, forKey: .quoteResponse){
            self.data = try? quoteResponseContainer.decodeIfPresent([StockQuoteYahoo].self, forKey: .result)
            self.error = try? quoteResponseContainer.decodeIfPresent(ErrorResponse.self, forKey: .error )
        } else if let financeResponseContainer = try? container.nestedContainer(keyedBy: ResponseKeys.self, forKey: .finance){
            self.data = try? financeResponseContainer.decodeIfPresent([StockQuoteYahoo].self, forKey: .result)
            self.error = try? financeResponseContainer.decodeIfPresent(ErrorResponse.self, forKey: .error )
        } else{
            self.data = nil
            self.error = nil
        }
    }
}
