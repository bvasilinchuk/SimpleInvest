//
//  StockCompanyData.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 12.03.2023.
//

import Foundation

struct CompanyData: Decodable {
    let description: String
    let currency: String
    let marketCap: Double
    let ebitda: Double
    let peRatio: Double
    let dividendsPastYear: Double
    let dividendYield: Double
    let fiftyTwoWeekHigh: Double
    let fiftyTwoWeekLow: Double
    
    enum CodingKeys: String, CodingKey {
        case description = "Description"
        case currency = "Currency"
        case marketCap = "MarketCapitalization"
        case ebitda = "EBITDA"
        case peRatio = "PERatio"
        case dividendsPastYear = "DividendPerShare"
        case dividendYield = "DividendYield"
        case fiftyTwoWeekHigh = "52WeekHigh"
        case fiftyTwoWeekLow = "52WeekLow"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.currency = try container.decode(String.self, forKey: .currency)
        
        if let marketCap = try container.decodeIfPresent(String.self, forKey: .marketCap) {
            guard let marketCap = Double(marketCap) else {
                throw DecodingError.dataCorruptedError(forKey: .marketCap, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.marketCap = marketCap
        } else {
            self.marketCap = 0.0 // Set a default value if the key is missing or null
        }
        
        
        if let ebitda = try container.decodeIfPresent(String.self, forKey: .ebitda) {
            guard let ebitda = Double(ebitda) else {
                throw DecodingError.dataCorruptedError(forKey: .ebitda, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.ebitda = ebitda
        } else {
            self.ebitda = 0.0 // Set a default value if the key is missing or null
        }
        
        if let peRatio = try container.decodeIfPresent(String.self, forKey: .peRatio) {
            guard let peRatio = Double(peRatio) else {
                throw DecodingError.dataCorruptedError(forKey: .peRatio, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.peRatio = peRatio
        } else {
            self.peRatio = 0.0 // Set a default value if the key is missing or null
        }
        
        if let dividendsPastYear = try container.decodeIfPresent(String.self, forKey: .dividendsPastYear) {
            guard let dividendsPastYear = Double(dividendsPastYear) else {
                throw DecodingError.dataCorruptedError(forKey: .dividendsPastYear, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.dividendsPastYear = dividendsPastYear
        } else {
            self.dividendsPastYear = 0.0 // Set a default value if the key is missing or null
        }
        
        if let dividendYield = try container.decodeIfPresent(String.self, forKey: .dividendYield) {
            guard let dividendYield = Double(dividendYield) else {
                throw DecodingError.dataCorruptedError(forKey: .dividendYield, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.dividendYield = dividendYield
        } else {
            self.dividendYield = 0.0 // Set a default value if the key is missing or null
        }
        
        if let fiftyTwoWeekHigh = try container.decodeIfPresent(String.self, forKey: .fiftyTwoWeekHigh) {
            guard let fiftyTwoWeekHigh = Double(fiftyTwoWeekHigh) else {
                throw DecodingError.dataCorruptedError(forKey: .fiftyTwoWeekHigh, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.fiftyTwoWeekHigh = fiftyTwoWeekHigh
        } else {
            self.fiftyTwoWeekHigh = 0.0 // Set a default value if the key is missing or null
        }
        
        if let fiftyTwoWeekLow = try container.decodeIfPresent(String.self, forKey: .fiftyTwoWeekLow) {
            guard let fiftyTwoWeekLow = Double(fiftyTwoWeekLow) else {
                throw DecodingError.dataCorruptedError(forKey: .fiftyTwoWeekLow, in: container, debugDescription: "Could not convert API response to double.")
            }
            self.fiftyTwoWeekLow = fiftyTwoWeekLow
        } else {
            self.fiftyTwoWeekLow = 0.0 // Set a default value if the key is missing or null
        }

    }
}
