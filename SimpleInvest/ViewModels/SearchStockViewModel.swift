//
//  SearchStockViewModel.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 08.02.2023.
//

import Foundation
@MainActor
class SearchStockViewModel: ObservableObject{
    @Published var matchedStocks: [SearchStock] = []
    let stocksAPI = StocksAPI()

    func fetchStocks(ticker: String) async throws -> [SearchStock]{
        guard let url = URL(string:"https://query1.finance.yahoo.com/v1/finance/search?q=\(ticker)")else {
            throw APIServiceError.invalidURL
        }
        let (response, statusCode): (SearchStockResponse, Int) = try await stocksAPI.fetch(url: url)
        guard let response = response.stocks else{
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: response.error)
        }
        print("stockData fetched with status code \(statusCode)")
        return response
    }
    
    func clearList(){
        matchedStocks = []
    }
    
    func getStockAsync(ticker: String, completion: @escaping () -> ()) {
        print("getStockAsync works for ticker:\(ticker)")
        if ticker == "" {
            matchedStocks = []
        } else {
        Task{
            do{
                let stock = try? await fetchStocks(ticker: ticker)
                if let stock = stock {
                    let result = stock.filter({$0.name != nil})
                    matchedStocks = Array(result.prefix(6))
                }
            }
            
        }
        completion()
        }
    }
}
