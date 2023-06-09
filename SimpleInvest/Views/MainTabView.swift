//
//  MainTabView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    @StateObject var stocksViewModel: StocksViewModel
    @StateObject var searchViewModel = SearchStockViewModel(matchedStocks: [])
    var body: some View {
        Group{
            if authModel.user != nil {
                TabView{
                    HomeView().tabItem{
                        Label("Main", systemImage: "house")
                    }
                    SearchBarView()
                        .tabItem{
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    AccountView()
                        .tabItem{
                            Label("Account", systemImage: "person")
                        }
                }
                .environmentObject(stocksViewModel)
                .environmentObject(searchViewModel)
            } else {
                LoginView()
                    .environmentObject(stocksViewModel)
            }
        }
        .onAppear(perform: {
            print("mainTabViewappeared")
            Task{
                do{
                    if authModel.user != nil{
                        let email = authModel.user?.email ?? "nil"
                        print("current user state \(email)")
                        stocksViewModel.initialFetch()
                    } else{
                        print("user in maintabview appeared to be nil. Fetch not executed")
                    }
                }
            }
        })
    }
}
//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView(email: "")
//    }
//}
