//
//  SplashView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 04.03.2023.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if viewModel.showMainView {
            let email = viewModel.user?.email ?? ""
            MainTabView(stocksViewModel: StocksViewModel(email: email, stocks: [Stock]()))
        } else{
            ZStack{
                Color("blue")
                    .ignoresSafeArea()
//                    // Add your splash screen content here
//                    Text("SimpleInvest")
//                        .foregroundColor(.white)
//                        .font(.title)
//                        .bold()
                .onAppear {
                    viewModel.listenToAuthState()
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
