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

struct SearchNews: Decodable, Hashable, Identifiable{
    var id = UUID()
    var title: String?
    var publisher: String?
    var link: String?
    var providerPublishTime: Date?
    var type: String?
    var thumbnail: Thumbnail?
    var relatedTickers: [String]
    
    enum CodingKeys: CodingKey{
        case title
        case publisher
        case link
        case providerPublishTime
        case type
        case thumbnail
        case relatedTickers
    }
}

struct Thumbnail: Decodable, Hashable, Identifiable{
    var id = UUID()
    var resolutions: [Resolution]
    
    enum CodingKeys: CodingKey{
        case resolutions
    }
}

struct Resolution: Decodable, Hashable, Identifiable{
    var id = UUID()
    var url: String
    
    enum CodingKeys: CodingKey{
        case url
    }
}

struct SearchStockResponse: Decodable {
    let stocks: [SearchStock]?
    let error: ErrorResponse?
    let news: [SearchNews]?
    
    enum CodingKeys: CodingKey {
        case quotes
        case finance
        case news
    }
    enum FinanceKeys: CodingKey {
        case result
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try? container.decodeIfPresent([SearchStock].self, forKey: .quotes),
           let news = try? container.decodeIfPresent([SearchNews].self, forKey: .news){
            self.stocks = data
            self.news = news
            self.error = nil
        } else if let responseContainer = try? container.nestedContainer(keyedBy: FinanceKeys.self, forKey: .finance){
            self.error = try? responseContainer.decodeIfPresent(ErrorResponse.self, forKey: .error)
            self.stocks = nil
            self.news = nil
            }
        else{
            self.stocks = nil
            self.error = nil
            self.news = nil
        }
    }
}

