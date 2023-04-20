//
//  SearchStockViewModel.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 08.02.2023.
//

import Foundation
import Combine
@MainActor
class SearchStockViewModel: ObservableObject{
    @Published var matchedStocks: [SearchStock] = []
    @Published var searchString = ""
    let stocksAPI = StocksAPI()
    init(matchedStocks: [SearchStock], searchString: String = "") {
        self.matchedStocks = matchedStocks
        self.searchString = searchString
        startObserving()
    }

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
        searchString = ""
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
    private var cancellables = Set<AnyCancellable>()
    
    private func startObserving() {
        $searchString
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { _ in
                Task { [weak self] in self?.getStockAsync(ticker:self?.searchString ?? "", completion:{}) }

                print("sink was triggered")
            }
            .store(in: &cancellables)
        
//        $searchString
//            .filter { $0.isEmpty }
//            .sink { [weak self] _ in self?.phase = .initial }
//            .store(in: &cancellables)
    }
    
    
}
