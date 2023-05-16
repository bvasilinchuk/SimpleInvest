//
//  ChartViewModel.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 15.04.2023.
//

import Foundation
import SwiftUI
import Charts

@MainActor
class ChartViewModel: ObservableObject{
    @Published var fetchPhase = FetchPhase<ChartViewData>.initial
    var chart: ChartViewData? {fetchPhase.value}
    let stock: Stock
    let stocksAPI = StocksAPI()
    
    @AppStorage("selectedRange") private var _range = ChartRange.oneDay.rawValue
    
    @Published var selectedRange = ChartRange.oneDay{
        didSet{
            print("range was changed to \(selectedRange)")
            _range = selectedRange.rawValue
        }
    }
    
    @Published var selectedX: (any Plottable)?
    

//
    private let dateFormatter = DateFormatter()
    
    private let selectedValueDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    var selectedXDateAndPriceText: (value: Int, date: String, price: String)? {
        guard let selectedX = selectedX as? Int, let chart else {return (nil)}
        if selectedRange == .oneDay || selectedRange == .oneWeek{
            selectedValueDateFormatter.timeStyle = .medium
        } else{
            selectedValueDateFormatter.timeStyle = .none
        }
        let item = chart.items[selectedX]
        let date = selectedValueDateFormatter.string(from: item.timestamp)
        let price = String(format: "%.2f", item.value) + " $"
        return (selectedX, date, price)
    }
    
    var selectedXOpacity: Double{
        selectedX == nil ? 1 : 0
    }
    
//    var selectedXRuleMark: (value: Date, text: String)? {
//        guard let selectedX = selectedX as? Date, let chart else {return nil}
//        return (selectedX, String(format: "%.2f", chart.items[index].value))
//    }
    
    var foregroundMarkColor: Color{
        selectedX != nil ? .cyan : chart?.lineColor ?? .cyan
    }
    
    init(stock: Stock) {
        self.stock = stock
        self.selectedRange = ChartRange(rawValue: _range) ?? .oneDay
    }
    
    func fetchData() async {
        do {
            fetchPhase = .fetching
            let rangeType = selectedRange
            guard let url = URL(string:"https://query1.finance.yahoo.com/v8/finance/chart/\(stock.ticker)?range=\(rangeType.rawValue)&interval=\(rangeType.interval)&indicators=quote&includeTimestamps=true")else {
                throw APIServiceError.invalidURL
            }
            let (response, statusCode): (ChartResponse, Int) = try await stocksAPI.fetch(url: url)
            guard let response = response.data?.first else{
                fetchPhase = .empty
                throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: response.error)
            }
            guard rangeType == selectedRange else {return}
            print("stockChart  fetched with status code \(statusCode)")
            fetchPhase = .success(transformChartViewData(response))
        } catch{
            fetchPhase = .failure(error)
        }
    }
    
    func transformChartViewData(_ data: ChartData) -> ChartViewData {
        let (xAxisChartData, items) = xAxisChartDataAndItems(data)
        return ChartViewData(xAxisData: xAxisChartData, yAxisData: yAxisChartData(data), items: items, lineColor: getLineColor(data: data))
    }
    
    func xAxisChartDataAndItems(_ data: ChartData) -> (ChartAxisData, [ChartViewItem]){
        let timeZone = TimeZone(secondsFromGMT: data.meta.gmtOffset) ?? .gmt
        dateFormatter.timeZone = timeZone
        selectedValueDateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = selectedRange.dateFormat
        
        var xAxisDateComponents = Set<DateComponents>()
        if let startTimestamp = data.indicators.first?.timestamp{
            if selectedRange == .oneDay{ if let endTimeStamp = data.meta.regularTradingPeriodEndDate{
                xAxisDateComponents = selectedRange.getDateComponents(startDate: startTimestamp, endDate: endTimeStamp, timezone: timeZone)
            }
            } else if let endTimeStamp = data.indicators.last?.timestamp {
                xAxisDateComponents = selectedRange.getDateComponents(startDate: startTimestamp, endDate: endTimeStamp, timezone: timeZone)
            }
        }
        var map = [String: String]()
        var axisEnd: Int
        
        var items = [ChartViewItem]()
        
        for (index, value) in data.indicators.enumerated(){
            let dc = value.timestamp.dateComponents(timeZone: timeZone, rangeType: selectedRange)
            if xAxisDateComponents.contains(dc){
                map[String(index)] = dateFormatter.string(from: value.timestamp)
                xAxisDateComponents.remove(dc)
            }
            items.append(ChartViewItem(timestamp: value.timestamp, value: value.close))
        }
        axisEnd = items.count - 1
        
        if selectedRange == .oneDay,
           var date = items.last?.timestamp,
           date >= data.meta.regularTradingPeriodStartDate! && date < data.meta.regularTradingPeriodEndDate!{
            while date < data.meta.regularTradingPeriodEndDate!{
                axisEnd += 1
                date = Calendar.current.date(byAdding: .minute, value: 2, to: date)!
                let dc = date.dateComponents(timeZone: timeZone, rangeType: selectedRange)
                if xAxisDateComponents.contains(dc){
                    map[String(axisEnd)] = dateFormatter.string(from: date)
                    xAxisDateComponents.remove(dc)
                }
            }
        }
        
        let xAxisData = ChartAxisData(axisStart: 0, axisEnd: Double(axisEnd), strideBy: 1, map: map )
        return (xAxisData, items)
        
    }
    
    func yAxisChartData(_ data: ChartData) -> ChartAxisData{
        let closes = data.indicators.map { $0.close }
        let lowest = closes.min() ?? 0
        let highest = closes.max() ?? 0
        return ChartAxisData(axisStart: lowest + 0.01, axisEnd: highest + 0.01, strideBy: 0, map: [:])
    }
    
    func getLineColor(data: ChartData) -> Color {
        guard let first = data.indicators.first, let last = data.indicators.last else {return .blue}
        if first.close < last.close{
            return .green
            } else{
                return .red
            }
    }
    
}
