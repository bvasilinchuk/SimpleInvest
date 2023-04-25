//
//  AccountView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 25.02.2023.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var stocksViewModel: StocksViewModel
    var body: some View {
        VStack{
            Spacer()
            Text(authViewModel.user?.email ?? "")
                .font(.title2)
            Button(action: {
                stocksViewModel.removeStocks()
                authViewModel.user = nil
                authViewModel.signOut()
            }, label: {Text("Log Out")
                    .font(.title3.bold())
            })
            .padding()
                Spacer()
                Button(action: {
                    authViewModel.deleteUser(completion: {stocksViewModel.deleteAllStocksFirebase()})
                }, label: {Text("Delete Account")
                        .foregroundColor(.red)
                })
                .padding()
                .alert(authViewModel.error?.localizedDescription ?? "Unknown error", isPresented: $authViewModel.hasError, actions: {Text("OK")})
        }
    }
}

//struct AccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountView().environmentObject({ () -> AuthViewModel in
//                            let envObj = AuthViewModel()
//                            return envObj
//                        }() )
//        .environmentObject({ () -> StocksViewModel in
//            let envObj = StocksViewModel(email: "test@mail.com",  stocks: Stock.previewStocks, stockRefs: <#[StockReference]#>)
//                            return envObj
//                        }() )
//    }
//}
