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
    enum MyResult<T> {
        case success(T)
        case failure(Error)
    }
    init(email: String, stocks: [Stock], stockRefs: [StockReference]){
        self.email = email
        self.stocks = stocks
        self.stockRefs = stockRefs
    }
    @Published var stockRefs = [StockReference]()

    @Published var stocks = [Stock]()
    let dbReference = Firestore.firestore()
    @Published var isLoading: Bool = false
    var email: String
    let stocksAPI = StocksAPI()
    var totalValue: Double {
        var sum = 0.0
        for stock in stocks {
            sum += Double(stock.quantity) * (stock.currentPrice ?? 0)
        }
        return roundFunc(sum)
    }
    var totalProfitCash: Double {
        var sum = 0.0
        for stock in stocks {
            sum += Double(stock.quantity) * stock.averagePrice
        }
        return roundFunc(totalValue - sum)
    }
    var totalProfitPercent: Double {
        var sum = 0.0
        for stock in stocks {
            sum += Double(stock.quantity) * stock.averagePrice
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
            value = value + (Double(stock.quantity) * (stock.dividendsPastYear ?? 0))
        }
        return value
    }
    
    
//    func getStockAsync(ticker: String, name: String, quantity: Double, averagePrice: Double, completion: @escaping () -> ()) {
//        Task{
//            isLoading = true
//            do{
//                print("2. \(String.timestamp())")
//                let stockFromYahoo = try? await fetchStockDataYahoo(ticker: ticker)
//                let stockSummaryFromYahoo = try? await fetchStockSummaryYahoo(ticker: ticker)
//                if let stock = stockFromYahoo?.data?[0]{
//                    if let stockSummary = stockSummaryFromYahoo?.data?[0].summaryProfile{
//                        let stockToIncert = Stock(currentPrice: stock.regularMarketPrice ?? 0.0, quantity: quantity, name: name, ticker: ticker, description: stockSummary.longBusinessSummary ?? "", currency: stock.financialCurrency ?? "", marketCap: stock.marketCap ?? 0.0, peRatio: stock.trailingPE ?? 0.0, dividendsPastYear: stock.trailingAnnualDividendRate ?? 0.0, dividendYield: stock.trailingAnnualDividendYield ?? 0.0, fiftyTwoWeekHigh: stock.fiftyTwoWeekHigh ?? 0.0, fiftyTwoWeekLow: stock.fiftyTwoWeekLow ?? 0.0, averagePrice: averagePrice, marketCapText: stock.mktCapText)
//                        print("stock \(stockToIncert.ticker) is ready to be added to array")
////                        addOrUpdateStockFirebase(stock: stockToIncert)
//                        fetchStocks()
//                        try await Task.sleep(nanoseconds: 500_000_000)
//                    }
//                }
//                isLoading = false
//                completion()
//
//            } catch{
//                print("Error from getStockAsync is \(error.localizedDescription)")
//            }
//
//        }
//    }
    
    func getStockAsync(ticker: String, name: String, quantity: Double, averagePrice: Double, completion: @escaping () -> ()) {
        if !ticker.isEmpty{
            Task{
                isLoading = true
                do{
                    print("2. \(String.timestamp())")
                    let stockToIncert = Stock(quantity: Int(quantity), name: name, ticker: ticker, averagePrice: averagePrice)
                    addOrUpdateStockFirebase(stock: stockToIncert)
                    initialFetch()
                    try await Task.sleep(nanoseconds: 500_000_000)
                } catch {
                    print("Error from getStockAsync is \(error.localizedDescription)")
                }
                isLoading = false
                completion()
            }
        }
    }

    
    func roundFunc(_ number: Double) -> Double{
        round(number * 100) / 100.0
    }
    
    func fetchStocks(completion: @escaping (MyResult<Int>) -> Void) {
        print("fetching stocks from firebase with email \(email)")
        stockRefs.removeAll()
        let ref = dbReference.collection(email)
        ref.getDocuments{ snapshot, error in
            guard error == nil else{
                print(error!.localizedDescription)
                completion(.failure(APIServiceError.invalidResponseType))
                return
            }
            if let snapshot = snapshot {
                for i in snapshot.documents.indices{
                    let snapshot = snapshot.documents[i]
                    let data = snapshot.data()
                    let quantity = data["quantity"] as? Int ?? 0
                    let ticker = data["ticker"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let averagePrice = data["averagePrice"] as? Double ?? 0
                    let documentId = snapshot.documentID
                    let stock = StockReference(firebaseId: documentId, name: name, ticker: ticker, averagePrice: averagePrice, quantity: quantity)
                    self.stockRefs.append(stock)
                }
                print("\(String.timestamp()) Array of stocks fetched from firebase: \(self.stockRefs)")
            }
            completion(.success(1))
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
        ref.addDocument(data: ["quantity": stock.quantity, "ticker": stock.ticker, "name": stock.name, "averagePrice": stock.averagePrice]) { error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func UpdateStockFirebase(stock: Stock){
        let ref = dbReference.collection(email).document(stock.firebaseId)
        ref.setData(["quantity": stock.quantity, "ticker": stock.ticker, "name": stock.name, "averagePrice": stock.averagePrice]) { error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func removeStocks (){
        stocks.removeAll()
        stockRefs.removeAll()
    }
    
    func deleteAllStocksFirebase(){
        let collectionRef = dbReference.collection(email)
        let batch = collectionRef.firestore.batch()
        for stock in stocks{
            batch.deleteDocument(collectionRef.document(stock.firebaseId))
        }
        batch.commit { error in
            if let error = error {
                print("Error deleting documents: \(error.localizedDescription)")
            } else {
                print("Documents deleted successfully")
                // update the data array to reflect the deletion
                self.stocks.removeAll()
            }
        }
    }
    
    func deleteFromFirebase(indexSet: IndexSet) {
        print("delete initiated for \(indexSet)")
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
                self.fetchStocks(completion: {_ in})
            }
        }
        
    }
    
    
//    func updateAllStocks() {
//        let collectionRef = dbReference.collection(email)
//        let batch = collectionRef.firestore.batch()
//        var tickersArray = [String]()
//        var documentIdArray = [String]()
//        if !stocks.isEmpty{
//            for stock in stocks{
//                tickersArray.append(stock.ticker)
//                documentIdArray.append(stock.firebaseId)
//            }
//            let tickers: String = tickersArray.joined(separator: ",")
//            Task{
//                do{
//                    let stockData = try? await fetchStockDataYahoo(ticker: tickers)
//                    if let stockData = stockData?.data{
//                        for i in stockData.indices{
//                            batch.updateData(["currentPrice": stockData[i].regularMarketPrice ?? 0.0, "marketCap": stockData[i].marketCap ?? 0.0, "peRatio": stockData[i].trailingPE ?? 0.0, "dividendsPastYear": stockData[i].trailingAnnualDividendRate ?? 0.0, "dividendYield": stockData[i].trailingAnnualDividendYield ?? 0.0, "fiftyTwoWeekHigh": stockData[i].fiftyTwoWeekHigh ?? 0.0, "fiftyTwoWeekLow": stockData[i].fiftyTwoWeekLow ?? 0.0], forDocument: collectionRef.document(documentIdArray[i]))
//                        }
//                        batch.commit { error in
//                            if let error = error {
//                                print("Error updating stocks: \(error.localizedDescription)")
//                            } else {
//                                print("All stocks updated successfully")
//                            }
//                        }
//                    }
//
//                }
//            }
//        }
//    }
    
//
    func fetchAllStocks(completion: @escaping (MyResult<Int>) -> Void){
        print("\(String.timestamp()) fetchAllStocks initiated")
        var tickersArray = [String]()
        var documentIdArray = [String]()
        for stock in stockRefs{
            tickersArray.append(stock.ticker)
            documentIdArray.append(stock.firebaseId)
        }
        let tickers: String = tickersArray.joined(separator: ",")
        Task{
            do{
                let stockData = try? await fetchStockDataYahoo(ticker: tickers)
                if let stockData = stockData?.data{
                    for i in stockData.indices{
                        let item = stockData[i]
                        let stock = Stock(firebaseId: stockRefs[i].firebaseId, currentPrice: item.regularMarketPrice, quantity: stockRefs[i].quantity, name: stockRefs[i].name, ticker: stockRefs[i].ticker, marketCap: item.marketCap, peRatio: item.peText, dividendsPastYear: item.trailingAnnualDividendRate, divRatePastYearText: item.divRateText, dividendYield: item.trailingAnnualDividendYield, fiftyTwoWeekHigh: item.fiftyTwoWeekHigh, fiftyTwoWeekLow: item.fiftyTwoWeekLow, averagePrice: stockRefs[i].averagePrice, marketCapText: item.mktCapText, epsText: item.epsText, beta: item.betaText, priceToBook: item.priceToBookText, dividendDate: item.dividendDate)
                        // Checking if stock already exists in array, if not, append the new stock object to the array
                        if !self.stocks.contains(where: { $0.ticker == item.symbol }){
                            stocks.append(stock)
                        } else{
                            //                                If stock is already in array we will update its value
                            if let index = self.stocks.firstIndex(where: {stock in stock.ticker == stockData[i].symbol}) {
                                self.stocks[index] = stock
                            }
                            
                        }
                    }
                }
                print("Fetched all socks for tickers: \(tickers)")
                completion(.success(1))
            }
        }
    }
    
    func initialFetch(){
        self.isLoading = true
        print("initialFetch started")
        fetchStocks() { [weak self] result in
            guard let self = self else {return}
            switch result{
            case .success(_):
                self.fetchAllStocks() { [weak self] result in
                    guard let self = self else {return}
                    switch result{
                    case.success(_):
                        self.isLoading = false
                    case.failure(_):
                        print("failure in fetchApiStocks in initial fetch")
                    }
                }
            case.failure(_):
                print("failure in fetchStocks")
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
