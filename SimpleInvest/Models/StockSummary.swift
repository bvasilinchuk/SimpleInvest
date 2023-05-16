//
//  StockCompanyData.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 12.03.2023.
//

import Foundation

//https://query2.finance.yahoo.com/v10/finance/quoteSummary/AAPL?modules=summaryProfile

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
