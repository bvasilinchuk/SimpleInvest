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
    let regularMarketChange: Double?
    let postMarketPrice: Double?
    let postMarketChange: Double?
    let regularMarketDayHigh: Double?
    let regularMarketOpen: Double?
    let regularMarketDayLow: Double?
    let regularMarketVolume: Double?
    let averageDailyVolume3Month: Double?
    let epsTrailingTwelveMonths: Double?
    let priceToBook: Double?
    let averageAnalystRating: String?
    let dividendDate: Date?
    let symbol: String
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



extension StockQuoteYahoo{
    var regularPriceText: String? {
        Utils.format(value: regularMarketPrice)
    }
    
    var regularDiffText: String? {
        guard let text = Utils.format(value: regularMarketChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
    
    var postPriceText: String? {
        Utils.format(value: postMarketPrice)
    }
    
    var postPriceDiffText: String? {
        guard let text = Utils.format(value: postMarketChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
    
    var highText: String {
        Utils.format(value: regularMarketDayHigh) ?? "-"
    }
    
    var openText: String {
        Utils.format(value: regularMarketOpen) ?? "-"
    }
    
    var lowText: String {
        Utils.format(value: regularMarketDayLow) ?? "-"
    }
    
    var volText: String {
        regularMarketVolume?.formatUsingAbbrevation() ?? "-"
    }
    
    var peText: String {
        Utils.format(value: trailingPE) ?? "-"
    }
    
    var mktCapText: String {
        marketCap?.formatUsingAbbrevation() ?? "-"
    }
    
    var fiftyTwoWHText: String {
        Utils.format(value: fiftyTwoWeekHigh) ?? "-"
    }
    
    var fiftyTwoWLText: String {
        Utils.format(value: fiftyTwoWeekLow) ?? "-"
    }
    
    var avgVolText: String {
        averageDailyVolume3Month?.formatUsingAbbrevation() ?? "-"
    }
    
    var divRateText: String{
        trailingAnnualDividendRate?.formatUsingAbbrevation() ?? "-"
    }
    
    var priceToBookText: String{
        priceToBook?.formatUsingAbbrevation() ?? "-"
    }
    
    var yieldText: String { "-" }
    var betaText: String { "-" }
    
    var epsText: String {
        Utils.format(value: epsTrailingTwelveMonths) ?? "-"
    }
}
