//
//  SearchStockViewModel.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 08.02.2023.
//

import Foundation
@MainActor
class SearchStockViewModel: ObservableObject{
//    @Published var matchedStocks: [SearchResult] = []
    @Published var matchedStocks: [SearchStock] = []
    
    //Welcome to Alpha Vantage! Your API key is: 3HZXZ31II44BDOPT. Please record this API key at a safe place for future data access.
    
    func fetchStocks(ticker: String) async throws ->
//    [SearchResult]
    [SearchStock]
    {
//        guard let url = URL(string: "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(ticker)&apikey=3HZXZ31II44BDOPT")
        guard let url = URL(string:"https://query1.finance.yahoo.com/v1/finance/search?q=\(ticker)")else {
//            return [SearchResult]()
            print("could not reach url")
            return [SearchStock]()

        }
            async let (data, _) = await URLSession.shared.data(from: url)
//            let response = try await JSONDecoder().decode(ResponseSearch.self, from: data)
        let response = try await JSONDecoder().decode(SearchStockResponse.self, from: data)
        if let response = response.stocks{
            print("SearchStock success response is \(response)")
            return response
        } else {
            print("Could not unwrap optional\(try await String(data: data, encoding: .utf8) ?? "no value")")
            return [SearchStock]()
            
        }
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
    
    
    //Functions that will use Yahoo Finance API
    
}
