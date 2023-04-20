//
//  StocksNewModel.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import Foundation

import Firebase //БД

@MainActor //нужен для того чтобы все происходило в main thread, так как на это завязаны обновления UI

class StocksViewModel: ObservableObject {
    init(email: String, stocks: [Stock]){
        self.email = email
        self.stocks = stocks
    }

    @Published var stocks = [Stock]()
    let dbReference = Firestore.firestore()
    @Published var isLoading: Bool = false
    var email: String
    let stocksAPI = StocksAPI()
    var totalValue: Double {
        var sum = 0.0
        for stock in stocks {
            sum += stock.quantity * stock.currentPrice
        }
        return roundFunc(sum)
    }
    var totalProfitCash: Double {
        var sum = 0.0
        for stock in stocks {
            sum += stock.quantity * stock.averagePrice
        }
        return roundFunc(totalValue - sum)
    }
    var totalProfitPercent: Double {
        var sum = 0.0
        for stock in stocks {
            sum += stock.quantity * stock.averagePrice
        }
        if sum == 0{
            return 0
        } else{
            return abs(roundFunc(((totalValue / sum) * 100)) - 100)
        }
        
    }
    var totalYearlyDividendIncome: Double {
        var value = 0.0
        for stock in stocks {
            value = value + (stock.quantity * stock.dividendsPastYear)
        }
        return value
    }
    
    
    func getStockAsync(ticker: String, name: String, quantity: Double, averagePrice: Double, completion: @escaping () -> ()) {
        Task{
            isLoading = true
            do{
                print("2. \(String.timestamp())")
                let stockFromYahoo = try? await fetchStockDataYahoo(ticker: ticker)
                let stockSummaryFromYahoo = try? await fetchStockSummaryYahoo(ticker: ticker)
                if let stock = stockFromYahoo?.data?[0]{
                    if let stockSummary = stockSummaryFromYahoo?.data?[0].summaryProfile{
                        let stockToIncert = Stock(currentPrice: stock.regularMarketPrice ?? 0.0, quantity: quantity, name: name, ticker: ticker, description: stockSummary.longBusinessSummary ?? "", currency: stock.financialCurrency ?? "", marketCap: stock.marketCap ?? 0.0, peRatio: stock.trailingPE ?? 0.0, dividendsPastYear: stock.trailingAnnualDividendRate ?? 0.0, dividendYield: stock.trailingAnnualDividendYield ?? 0.0, fiftyTwoWeekHigh: stock.fiftyTwoWeekHigh ?? 0.0, fiftyTwoWeekLow: stock.fiftyTwoWeekLow ?? 0.0, averagePrice: averagePrice)
                        print("stock \(stockToIncert.ticker) is ready to be added to array")
                        addOrUpdateStockFirebase(stock: stockToIncert)
                        fetchStocks()
                        try await Task.sleep(nanoseconds: 500_000_000)
                    }
                }
                isLoading = false
                completion()
                
            } catch{
                print("Error from getStockAsync is \(error.localizedDescription)")
            }
            
        }
    }

    
    func roundFunc(_ number: Double) -> Double{
        round(number * 100) / 100.0
    }
    
    func fetchStocks(){
        isLoading = true
        print("fetchins stocks from firebase with email \(email)")
        let ref = dbReference.collection(email)
        ref.getDocuments{ snapshot, error in
            guard error == nil else{
                print(error!.localizedDescription)
                self.isLoading = false
                return
            }
            if let snapshot = snapshot {
                for i in snapshot.documents.indices{
                    let snapshot = snapshot.documents[i]
                    let data = snapshot.data()
                    let currentPrice = data["currentPrice"] as? Double ?? 0
                    let quantity = data["quantity"] as? Double ?? 0
                    let name = data["name"] as? String ?? ""
                    let ticker = data["ticker"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let currency = data["currency"] as? String ?? ""
                    let marketCap = data["marketCap"] as? Double ?? 0
                    let peRatio = data["peRatio"] as? Double ?? 0
                    let dividendsPastYear = data["dividendsPastYear"] as? Double ?? 0
                    let dividendYield = data["dividendYield"] as? Double ?? 0
                    let fiftyTwoWeekHigh = data["fiftyTwoWeekHigh"] as? Double ?? 0
                    let fiftyTwoWeekLow = data["fiftyTwoWeekLow"] as? Double ?? 0
                    let averagePrice = data["averagePrice"] as? Double ?? 0
                    let documentId = snapshot.documentID
                    
                    let stock = Stock(firebaseId: documentId, currentPrice: currentPrice, quantity: quantity, name: name, ticker: ticker, description: description, currency: currency, marketCap: marketCap, peRatio: peRatio, dividendsPastYear: dividendsPastYear, dividendYield: dividendYield, fiftyTwoWeekHigh: fiftyTwoWeekHigh, fiftyTwoWeekLow: fiftyTwoWeekLow, averagePrice: averagePrice)
                    if !self.stocks.contains(where: { $0.name == name }) {
                        // Checking if stock already exists in array, if not, append the new stock object to the array
                        self.stocks.append(stock)
                    } else{
                        //If stock is already in array we will update its value
                        if let index = self.stocks.firstIndex(where: {stock in stock.name == name}) {
                            self.stocks[index] = stock
                        }
                    }
                }
                self.isLoading = false
            }
        }
    }
    
}




extension StocksViewModel{
    
    func addOrUpdateStockFirebase(stock: Stock) {
        var stockTemp = stock
        let filtered = stocks.filter{$0.ticker == stock.ticker}
        if filtered.isEmpty{
            addStockFirebase(stock: stock)
        } else{
            stockTemp.firebaseId = filtered[0].firebaseId
            UpdateStockFirebase(stock: stockTemp)
        }
    }
    
    
    
    func addStockFirebase(stock: Stock){
        let ref = dbReference.collection(email)
        ref.addDocument(data: ["currentPrice": stock.currentPrice, "quantity": stock.quantity, "name": stock.name, "ticker": stock.ticker, "description": stock.description, "currency": stock.currency, "marketCap": stock.marketCap, "peRatio": stock.peRatio, "dividendsPastYear": stock.dividendsPastYear, "dividendYield": stock.dividendYield, "fiftyTwoWeekHigh": stock.fiftyTwoWeekHigh, "fiftyTwoWeekLow": stock.fiftyTwoWeekLow, "averagePrice": stock.averagePrice]) { error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func UpdateStockFirebase(stock: Stock){
        let ref = dbReference.collection(email).document(stock.firebaseId)
        ref.setData(["currentPrice": stock.currentPrice, "quantity": stock.quantity, "name": stock.name, "ticker": stock.ticker, "description": stock.description, "currency": stock.currency, "marketCap": stock.marketCap, "peRatio": stock.peRatio, "dividendsPastYear": stock.dividendsPastYear, "dividendYield": stock.dividendYield, "fiftyTwoWeekHigh": stock.fiftyTwoWeekHigh, "fiftyTwoWeekLow": stock.fiftyTwoWeekLow, "averagePrice": stock.averagePrice]) { error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func removeStocks (){
        stocks.removeAll()
    }
    
    func deleteFromFirebase(indexSet: IndexSet) {
        let collectionRef = dbReference.collection(email)
        let batch = collectionRef.firestore.batch()
        for index in indexSet {
            batch.deleteDocument(collectionRef.document(stocks[index].firebaseId))
        }
        print("deleting from \(email)")
        // commit the batch write
        batch.commit { error in
            if let error = error {
                print("Error deleting documents: \(error.localizedDescription)")
            } else {
                print("Documents deleted successfully")
                // update the data array to reflect the deletion
                self.stocks.remove(atOffsets: indexSet)
            }
        }
    }
    
    
    func updateAllStocks() {
        let collectionRef = dbReference.collection(email)
        let batch = collectionRef.firestore.batch()
        var tickersArray = [String]()
        var documentIdArray = [String]()
        if !stocks.isEmpty{
            for stock in stocks{
                tickersArray.append(stock.ticker)
                documentIdArray.append(stock.firebaseId)
            }
            let tickers: String = tickersArray.joined(separator: ",")
            Task{
                do{
                    let stockData = try? await fetchStockDataYahoo(ticker: tickers)
                    if let stockData = stockData?.data{
                        for i in stockData.indices{
                            batch.updateData(["currentPrice": stockData[i].regularMarketPrice ?? 0.0, "marketCap": stockData[i].marketCap ?? 0.0, "peRatio": stockData[i].trailingPE ?? 0.0, "dividendsPastYear": stockData[i].trailingAnnualDividendRate ?? 0.0, "dividendYield": stockData[i].trailingAnnualDividendYield ?? 0.0, "fiftyTwoWeekHigh": stockData[i].fiftyTwoWeekHigh ?? 0.0, "fiftyTwoWeekLow": stockData[i].fiftyTwoWeekLow ?? 0.0], forDocument: collectionRef.document(documentIdArray[i]))
                        }
                        batch.commit { error in
                            if let error = error {
                                print("Error updating stocks: \(error.localizedDescription)")
                            } else {
                                print("All stocks updated successfully")
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    //fetch Stock data (quote) from YahooFinance
    func fetchStockDataYahoo(ticker: String) async throws -> StockQuoteYahooResponse {
        print("UPDATED METHOD fetchstockdata from Yahoo is initiated for \(ticker)")
        guard let url = URL(string: "https://query1.finance.yahoo.com/v7/finance/quote?symbols=\(ticker)") else{
            throw APIServiceError.invalidURL
        }
        let (response, statusCode): (StockQuoteYahooResponse, Int) = try await stocksAPI.fetch(url: url)
        if let error = response.error {
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: error)
        }
        print("stockData fetched with status code \(statusCode)")
        return response
    }
    
    //fetch Stock summary from YahooFinance
    func fetchStockSummaryYahoo(ticker: String) async throws -> StockSummaryYahooResponse {
        print("fetchstocksummary from Yahoo is initiated for \(ticker)")
        guard let url = URL(string: "https://query2.finance.yahoo.com/v10/finance/quoteSummary/\(ticker)?modules=summaryProfile") else{
            throw APIServiceError.invalidURL
        }
        let (response, statusCode): (StockSummaryYahooResponse, Int) = try await stocksAPI.fetch(url: url)
        if let error = response.error {
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: error)
        }
        return response
    }
    
    //fetch stock chart data from YahooFinance
    func fetchChartData(ticker: String, range: ChartRange) async throws -> ChartData? {
        print("fetchChartData from Yahoo is initiated for \(ticker)")
        guard let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(ticker)?range=\(range.rawValue)&interval=\(range.interval)&indicators=quote&includeTimestamps=true") else{
            throw APIServiceError.invalidURL
        }
        let (response, statusCode): (ChartResponse, Int) = try await stocksAPI.fetch(url: url)
        if let error = response.error {
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: error)
        }
        return response.data?.first
    }
}
