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
    @Published var matchedNews: [SearchNews] = []
    @Published var searchString = ""
    let stocksAPI = StocksAPI()
    init(matchedStocks: [SearchStock], searchString: String = "") {
        self.matchedStocks = matchedStocks
        self.searchString = searchString
        startObserving()
    }

    func fetchStockSearchData(ticker: String) async throws -> ([SearchStock], [SearchNews]){
        guard let url = URL(string:"https://query1.finance.yahoo.com/v1/finance/search?q=\(ticker)")else {
            throw APIServiceError.invalidURL
        }
        let (response, statusCode): (SearchStockResponse, Int) = try await stocksAPI.fetch(url: url)
        guard let responseStock = response.stocks, let responseNews = response.news else{
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: response.error)
        }
        print("stockData fetched with status code \(statusCode)")
        print(responseNews.first?.title ?? "Nothing from news")
        return (responseStock, responseNews)
    }
    
    func clearList(){
        matchedStocks = []
        searchString = ""
    }
    
    func searchStocksAsync(ticker: String, completion: @escaping () -> ()) {
        print("getStockAsync works for ticker:\(ticker)")
        if ticker == "" {
            matchedStocks = []
        } else {
        Task{
            do{
                let stock = try? await fetchStockSearchData(ticker: ticker)
                if let stock = stock {
                    let result = stock.0.filter({$0.name != nil})
                    matchedStocks = Array(result.prefix(6))
                }
            }
        }
        completion()
        }
    }
    
    func getNewsAsync(ticker: String) {
        print("getNewsAsync works for ticker:\(ticker)")
        Task{
            do{
                let stock = try? await fetchStockSearchData(ticker: ticker)
                if let stock = stock {
                    let news = stock.1
                    matchedNews = news
                }
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func startObserving() {
        $searchString
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { _ in
                Task { [weak self] in self?.searchStocksAsync(ticker:self?.searchString ?? "", completion:{}) }

                print("sink was triggered")
            }
            .store(in: &cancellables)
    }
    private let selectedValueDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    
}
