//
//  StockFromAPI.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 12.03.2023.
//

import Foundation

//This is needed to Decode response from API call to obtain StockQuote
//The option with Yahoo Finance is below
struct StockQuote: Decodable {
    let symbol: String
    let open: Double
    let high: Double
    let low: Double
    let price: Double
    let volume: Double
    let latestTradingDay: String
    let previousClose: String
    let change: String
    let changePercent: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case open = "02. open"
        case high = "03. high"
        case low = "04. low"
        case price = "05. price"
        case volume = "06. volume"
        case latestTradingDay = "07. latest trading day"
        case previousClose = "08. previous close"
        case change = "09. change"
        case changePercent = "10. change percent"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        if let open = try container.decodeIfPresent(String.self, forKey: .open) {
            guard let apiResponseDouble1 = Double(open) else {
                throw DecodingError.dataCorruptedError(forKey: .open, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.open = apiResponseDouble1
        } else {
            self.open = 0.0 // Set a default value if the key is missing or null
        }
        
        
        if let high = try container.decodeIfPresent(String.self, forKey: .high) {
            guard let apiResponseDouble2 = Double(high) else {
                throw DecodingError.dataCorruptedError(forKey: .high, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.high = apiResponseDouble2
        } else {
            self.high = 0.0 // Set a default value if the key is missing or null
        }
        
        if let low = try container.decodeIfPresent(String.self, forKey: .low) {
            guard let low = Double(low) else {
                throw DecodingError.dataCorruptedError(forKey: .low, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.low = low
        } else {
            self.low = 0.0 // Set a default value if the key is missing or null
        }
        
        if let price = try container.decodeIfPresent(String.self, forKey: .price) {
            guard let price = Double(price) else {
                throw DecodingError.dataCorruptedError(forKey: .price, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.price = price
        } else {
            self.price = 0.0 // Set a default value if the key is missing or null
        }
        
        if let volume = try container.decodeIfPresent(String.self, forKey: .volume) {
            guard let volume = Double(volume) else {
                throw DecodingError.dataCorruptedError(forKey: .volume, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.volume = volume
        } else {
            self.volume = 0.0 // Set a default value if the key is missing or null
        }
        self.latestTradingDay = try container.decode(String.self, forKey: .latestTradingDay)
        self.previousClose = try container.decode(String.self, forKey: .previousClose)
        self.change = try container.decode(String.self, forKey: .change)
        self.changePercent = try container.decode(String.self, forKey: .changePercent)

    }
}


struct ResponseQuote: Decodable {
    let stock: StockQuote
    enum CodingKeys: String, CodingKey {
        case stock = "Global Quote"
    }
}

//The full response looks like this
//{
//"Global Quote": {
//    "01. symbol": "BAC",
//    "02. open": "30.3200",
//    "03. high": "31.0400",
//    "04. low": "28.9200",
//    "05. price": "30.2700",
//    "06. volume": "165330889",
//    "07. latest trading day": "2023-03-10",
//    "08. previous close": "30.5400",
//    "09. change": "-0.2700",
//    "10. change percent": "-0.8841%"
//}
//}



//Here would be StockQuote from https://query1.finance.yahoo.com/v7/finance/quote?symbols=AAPL

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



//Another Yahoo API with Stock Summary
//https://query2.finance.yahoo.com/v10/finance/quoteSummary/AMT?modules=summaryProfile


//{
//    "quoteSummary": {
//        "result": [
//            {
//                "summaryProfile": {
//                    "address1": "116 Huntington Avenue",
//                    "address2": "11th Floor",
//                    "city": "Boston",
//                    "state": "MA",
//                    "zip": "02116",
//                    "country": "United States",
//                    "phone": "617-375-7500",
//                    "fax": "617-375-7575",
//                    "website": "https://www.americantower.com",
//                    "industry": "REIT—Specialty",
//                    "sector": "Real Estate",
//                    "longBusinessSummary": "American Tower Corporation, one of the largest global REITs, is a leading independent owner, operator and developer of multitenant communications real estate with a portfolio of approximately 219,000 communications sites. For more information about American Tower, please visit the Earnings Materials and Investor Presentations sections of our investor relations website at www.americantower.com.",
//                    "fullTimeEmployees": 6391,
//                    "companyOfficers": [],
//                    "maxAge": 86400
//                }
//            }
//        ],
//        "error": null
//    }
//}


struct StockSummaryYahoo: Codable {
    let sector: String?
    let longBusinessSummary: String?
    let country: String?
}
struct Result: Codable{
    let summaryProfile: StockSummaryYahoo
}
    
struct StockSummaryYahooResponse: Decodable {
    let data: [Result]?
    let error: ErrorResponse?
    
    enum CodingKeys: CodingKey{
        case quoteSummary
    }
    
    enum ResponseKeys: CodingKey{
        case result
        case error
    }
    enum ResultKeys: CodingKey{
        case summaryProfile
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let quoteResponseContainer = try? container.nestedContainer(keyedBy: ResponseKeys.self, forKey: .quoteSummary){
            self.data = try? quoteResponseContainer.decodeIfPresent([Result].self, forKey: .result)
            self.error = try? quoteResponseContainer.decodeIfPresent(ErrorResponse.self, forKey: .error )
        }
        else{
            data = nil
            error = nil
        }
    }
}
