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
    @State var showStockView = false
    var body: some View {
        NavigationView{
        VStack{
            VStack{
                Text("Total value").font(.title)
                HStack{
                    Spacer()
                    Text("$\(stocksViewModel.totalValue, specifier: "%.2f")")
                        .font(.title.bold())
                    Spacer()
                    
                }
                
                Text("\(stocksViewModel.totalProfitCash<0 ? "":"+")\(stocksViewModel.totalProfitCash, specifier: "%.2f") $ · \(stocksViewModel.totalProfitPercent, specifier: "%.2f") %").lossProfitColor(value: stocksViewModel.totalProfitCash)
                HStack{
                    Spacer()
                    VStack{
                        Text("Dividend Income: ")
                            .font(.title3) + Text("$\(stocksViewModel.totalYearlyDividendIncome, specifier: "%.2f")")
                            .font(.title3.bold())
                        Text("(Trailing 12 months)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                }
                .padding(.top)
            }
            .padding()
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(10)
            .redacted(reason: stocksViewModel.isLoading ? .placeholder : [])
            .animatePlaceholder(isLoading: stocksViewModel.isLoading)
            ZStack{
                List { ForEach(stocksViewModel.stocks){stock in
                    NavigationLink(destination: StockTabView(stock: stock, chartViewModel: ChartViewModel(stock: stock)), label: {ListRowView(name: stock.name, price: stock.currentPrice, totalPrice: stock.totalPrice, ticker: stock.ticker, quantity: stock.quantity, profitCash: stock.averageProfitCash, profitPercent: stock.averageProfitPercent, placement: .home)})
                }
                .onDelete { indexSet in
                    stocksViewModel.deleteFromFirebase(indexSet: indexSet)
                }
                }
                .listStyle(.inset)
                if stocksViewModel.isLoading{
                    ProgressView()
                } else if stocksViewModel.stocks.isEmpty{
                    VStack{
                        Text("You don't have any assets yet.")
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .font(.title2)
                            .padding()
                    }
                }
            }
        }
        .padding()
        .navigationTitle("SimpleInvest")
        .refreshable {
            stocksViewModel.fetchAllStocksYahoo(completion: {_ in })
        }
    }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            stocksViewModel.fetchAllStocksYahoo(completion: {_ in })
        })

        .sheet(isPresented: $showSearchView, content: {SearchBarView()})
    }
                      
}
                  
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView().environmentObject({ () -> AuthViewModel in
//                            let envObj = AuthViewModel()
//                            return envObj
//                        }() )
//        .environmentObject({ () -> StocksViewModel in
//            let envObj = StocksViewModel(email: "test@mail.com",  stocks: Stock.previewStocks)
//                            return envObj
//                        }() )
//    }
//}
