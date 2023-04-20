//
//  ContentView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 05.02.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var stocksViewModel: StocksViewModel
    @EnvironmentObject var searchViewModel: SearchStockViewModel
    @State var showSearchView = false
    var body: some View {
        NavigationView{
        VStack{
            VStack{
                Text("Total value").font(.title.bold())
                    .padding()
                HStack{
                    Spacer()
                    Text("\(stocksViewModel.totalValue, specifier: "%.2f") $")
                        .font(.title)
                    Spacer()
                    
                }
                
                Text("\(stocksViewModel.totalProfitCash<0 ? "":"+")\(stocksViewModel.totalProfitCash, specifier: "%.2f") $ · \(stocksViewModel.totalProfitPercent, specifier: "%.2f") %").lossProfitColor(value: stocksViewModel.totalProfitCash)
                HStack{
                    Spacer()
                    Text("Dividend yield: \(stocksViewModel.totalYearlyDividendIncome, specifier: "%.2f") $")
                        .font(.title3)
                    Spacer()
                    
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.3))
            .cornerRadius(10)
            List { ForEach(stocksViewModel.stocks){stock in
                NavigationLink(destination: StockView(stock: stock, chartViewModel: ChartViewModel(stock: stock)), label: {ListRowView(name: stock.name, price: stock.currentPrice, totalPrice: stock.totalPrice, ticker: stock.ticker, quantity: stock.quantity, profitCash: stock.averageProfitCash, profitPercent: stock.averageProfitPercent, placement: .home)})
                
            }
            .onDelete { indexSet in
                stocksViewModel.deleteFromFirebase(indexSet: indexSet)
            }
        }
            .overlay(Group{
                if stocksViewModel.stocks.isEmpty {
                    if stocksViewModel.isLoading{
                        ProgressView()
                    } else{
                        VStack{
                            Text("You didn't add any assets yet")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }})
            .listStyle(.inset)
            Button(action: {
                Task{
                    do{
                        let response = try await stocksViewModel.fetchChartData(ticker: "AAPL", range: .twoYear)
                        if let response = response{
                            print(response)
                        }
                    }
                }
            }, label: {Text("update")})
        }
        .padding()
        .navigationTitle("SimpleInvest")
        .toolbar{
            Button(action: {showSearchView.toggle()}, label: {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.iconOnly)
            })
        }
        .refreshable {
            stocksViewModel.fetchStocks()
        }
    }
        .navigationBarTitleDisplayMode(.inline)
        // Не понимаю почему этот метод вызывается при логауте
        // Как было: после логаута при загрузке экрана логина вызывался fetchStocks со старой почтой. Из за этого дублировались данные от предыдущего аккаунта. Добавил проверку юзера, чтобы запрос не проходил на экране логина
        .onAppear(perform: {
            if authViewModel.user != nil {
                stocksViewModel.fetchStocks()
                stocksViewModel.updateAllStocks()
            }})

        .sheet(isPresented: $showSearchView, content: {SearchBarView()})
    }
                      
}
                  
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject({ () -> AuthViewModel in
                            let envObj = AuthViewModel()
                            return envObj
                        }() )
        .environmentObject({ () -> StocksViewModel in
            let envObj = StocksViewModel(email: "test@mail.com",  stocks: Stock.previewStocks)
                            return envObj
                        }() )
    }
}
