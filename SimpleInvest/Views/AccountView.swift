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
            Text(authViewModel.user?.email ?? "")
                .font(.title2)
            Button(action: {
                stocksViewModel.removeStocks()
                authViewModel.user = nil
                authViewModel.signOut()
            }, label: {Text("Log Out")})
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView().environmentObject({ () -> AuthViewModel in
                            let envObj = AuthViewModel()
                            return envObj
                        }() )
        .environmentObject({ () -> StocksViewModel in
            let envObj = StocksViewModel(email: "test@mail.com",  stocks: Stock.previewStocks)
                            return envObj
                        }() )
    }
}
