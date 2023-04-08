//
//  StockSearch.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 12.03.2023.
//

import Foundation

//Object from Yahoo API
//https://query1.finance.yahoo.com/v1/finance/search?q=Apple

struct SearchStock: Decodable, Hashable, Identifiable, Equatable {
    var id = UUID()
    let shortname: String?
    let type: String?
    let symbol: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case shortname
        case type = "quoteType"
        case symbol
        case name = "longname"
    }
}

struct SearchStockResponse: Decodable {
    let stocks: [SearchStock]?
    let error: ErrorResponse?
    
    enum CodingKeys: CodingKey {
        case quotes
        case finance
    }
    enum FinanceKeys: CodingKey {
        case result
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try? container.decodeIfPresent([SearchStock].self, forKey: .quotes){
            self.stocks = data
            self.error = nil
        } else if let responseContainer = try? container.nestedContainer(keyedBy: FinanceKeys.self, forKey: .finance){
            self.error = try? responseContainer.decodeIfPresent(ErrorResponse.self, forKey: .error)
            self.stocks = nil
            }
        else{
            self.stocks = nil
            self.error = nil
        }
    }
}

