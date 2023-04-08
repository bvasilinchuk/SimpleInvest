//
//  StockChart.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 03.04.2023.
//

import Foundation

//https://query1.finance.yahoo.com/v8/finance/chart/AAPL?range=1d&interval=1m&indicators=quote&includeTimestamps=true

struct ChartResponse: Decodable{
    let data: [ChartData]?
    let error: ErrorResponse?
    
    enum CodingKeys: CodingKey{
        case chart
    }
    
    enum ChartKeys: CodingKey{
        case result
        case error
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let chartContainer = try? container.nestedContainer(keyedBy: ChartKeys.self, forKey: .chart){
            data = try chartContainer.decodeIfPresent([ChartData].self, forKey: .result)
            error = try chartContainer.decodeIfPresent(ErrorResponse.self, forKey: .error)
        } else{
            self.data = nil
            self.error = nil
        }
    }
}

struct ChartData: Decodable{
    let meta: ChartMeta
    let indicators: [Indicator]
    enum CodingKeys: CodingKey{
        case meta
        case timestamp
        case indicators
    }
    enum IndicatorsKeys: CodingKey{
        case quote
    }
    enum QuoteKeys: CodingKey{
        case close
        case high
        case low
        case open
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        meta = try container.decode(ChartMeta.self, forKey: .meta)
        let timestamps = try container.decodeIfPresent([Date].self, forKey: .timestamp) ?? []
        
        if let indicatorContainer = try? container.nestedContainer(keyedBy: IndicatorsKeys.self, forKey: .indicators),
           var quotes = try? indicatorContainer.nestedUnkeyedContainer(forKey: .quote),
           let quoteContainer = try? quotes.nestedContainer(keyedBy: QuoteKeys.self){
            
            let highs = try quoteContainer.decodeIfPresent([Double?].self, forKey: .high) ?? []
            let lows = try quoteContainer.decodeIfPresent([Double?].self, forKey: .low) ?? []
            let opens = try quoteContainer.decodeIfPresent([Double?].self, forKey: .open) ?? []
            let closes = try quoteContainer.decodeIfPresent([Double?].self, forKey: .close) ?? []
            
            self.indicators = timestamps.enumerated().compactMap(){
                (offset, timestamp) in
                guard let open = opens[offset],
                        let close = closes[offset],
                      let high = highs[offset],
                      let low = lows[offset]
                else {return nil}
                return .init(timestamp: timestamp, close: close, low: low, high: high, open: open)            }
        } else{
            indicators = []
        }

    }

}

struct ChartMeta: Decodable{
    let currency: String
    let symbol: String
    let regularMarketPrice: Double?
    let previousClose: Double?
    let gmtOffset: Int
    let regularTradingPeriodStartDate: Date?
    let regularTradingPeriodEndDate: Date?
    
    enum CodingKeys: String, CodingKey{
        case currency
        case symbol
        case regularMarketPrice
        case previousClose
        case gmtoffset
        case currentTradingPeriod
    }
    
    enum CurrentTradingKeys: CodingKey{
        case pre
        case regular
        case post
    }
    enum TradingPeriodKeys: CodingKey{
        case start
        case end
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? ""
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
        self.regularMarketPrice = try container.decodeIfPresent(Double.self, forKey: .regularMarketPrice) ?? 0
        self.previousClose = try container.decodeIfPresent(Double.self, forKey: .previousClose) ?? 0
        self.gmtOffset = try container.decodeIfPresent(Int.self, forKey: .gmtoffset) ?? 0
        let tradingPeriodContainer = try container.nestedContainer(keyedBy: CurrentTradingKeys.self, forKey: .currentTradingPeriod)
        let regularTradingPeriodContainer = try tradingPeriodContainer.nestedContainer(keyedBy: TradingPeriodKeys.self, forKey: .regular)
        self.regularTradingPeriodStartDate = try regularTradingPeriodContainer.decodeIfPresent(Date.self, forKey: .start) ?? Date()
        self.regularTradingPeriodEndDate = try regularTradingPeriodContainer.decodeIfPresent(Date.self, forKey: .end) ?? Date()
    }
}

struct Indicator: Codable {
    let timestamp: Date
    let close: Double
    let low: Double
    let high: Double
    let open: Double
}
