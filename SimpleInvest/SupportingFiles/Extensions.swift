//
//  Extensions.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 28.02.2023.
//

import Foundation
import SwiftUI

// Добавляем функции к String:
//timestamp() для удобного вывода времени в консоль

extension String {
    static func timestamp() -> String {
        let dateFMT = DateFormatter()
        dateFMT.locale = Locale(identifier: "en_US_POSIX")
        dateFMT.dateFormat = "yyyyMMdd'T'HHmmss.SSSS"
        let now = Date()

        return String(format: "%@", dateFMT.string(from: now))
    }
}

extension Double{
    //https://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format
    //    gbitaudeau
        func formatUsingAbbrevation () -> String {
            let numFormatter = NumberFormatter()
            
            typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
            let abbreviations:[Abbrevation] = [(0, 1, ""),
                                               (1000.0, 1000.0, "K"),
                                               (100_000.0, 1_000_000.0, "M"),
                                               (100_000_000.0, 1_000_000_000.0, "B"),
                                               (100_000_000_000.0, 1_000_000_000_000.0, "T")]
            let startValue = Double (abs(self))
            let abbreviation:Abbrevation = {
                var prevAbbreviation = abbreviations[0]
                for tmpAbbreviation in abbreviations {
                    if (startValue < tmpAbbreviation.threshold) {
                        break
                    }
                    prevAbbreviation = tmpAbbreviation
                }
                return prevAbbreviation
            } ()
            
            let value = Double(self) / abbreviation.divisor
            numFormatter.positiveSuffix = abbreviation.suffix
            numFormatter.negativeSuffix = abbreviation.suffix
            numFormatter.allowsFloats = true
            numFormatter.minimumIntegerDigits = 1
            numFormatter.minimumFractionDigits = 0
            numFormatter.maximumFractionDigits = 3
            numFormatter.decimalSeparator = ","
            
            return numFormatter.string(from: NSNumber (value:value))!
        }
    var roundedString: String {
        String(format: "%.2f", self)
    }
}

struct LossProfitColor: ViewModifier {
    let value: Double
    
    func body(content: Content) -> some View {
        if value > 0{
            content.foregroundColor(.green)
        } else if value == 0 {
            content
        } else{
            content.foregroundColor(.red)
        }
    }
}

extension Text {
    func lossProfitColor(value: Double) -> some View {
        self.modifier(LossProfitColor(value: value))
    }
}

struct StandardButtonStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.headline)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .progressViewStyle(.circular)
                            .cornerRadius(10)
                            .padding()
        }
}


extension Date {
    
    func dateComponents(timeZone: TimeZone, rangeType: ChartRange, calendar: Calendar = .current) -> DateComponents {
        let current = calendar.dateComponents(in: timeZone, from: self)
        
        var dc = DateComponents(timeZone: timeZone, year: current.year, month: current.month)
        
        if rangeType == .oneMonth || rangeType == .oneWeek || rangeType == .oneDay {
            dc.day = current.day
        }
        
        if rangeType == .oneDay {
            dc.hour = current.hour
        }
        
        return dc
    }
    
}




#if DEBUG
struct MockStocksAPI {
    
    var stubbedSearchTickersCallback: (() async throws -> [SearchStock])!
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [SearchStock] {
        try await stubbedSearchTickersCallback()
    }
    
    var stubbedFetchQuotesCallback: (() async throws -> [StockQuoteYahoo])!
    func fetchQuotes(symbols: String) async throws -> [StockQuoteYahoo] {
        try await stubbedFetchQuotesCallback()
    }
    
    var stubbedFetchChartDataCallback: ((ChartRange) async throws  -> ChartData?)! = { $0.stubs }
    func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData? {
        try await stubbedFetchChartDataCallback(range)
    }
    
}
#endif


struct Utils {
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.currencyDecimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static func format(value: Double?) -> String? {
        guard let value,
              let text = numberFormatter.string(from: NSNumber(value: value))
        else { return nil }
        return text
    }
    
}
