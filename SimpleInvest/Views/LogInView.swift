//
//  LogInView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 19.02.2023.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var stocksViewModel: StocksViewModel
    @State private var email = ""
    @State private var password = ""
    @State var showSignUp = false
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                authViewModel.login(email: email, password: password, completion: {stocksViewModel.email = authViewModel.user?.email ?? ""
                    stocksViewModel.initialFetch()
                })
            }, label: {if authViewModel.isLoading{
                ProgressView()
                            } else{
                                Text("Login")
                            }})
            .buttonStyle(StandardButtonStyle())
            Spacer()
            HStack {
                Text("Don't have an account?")
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Sign up")
                }
            }
        }
        .padding()
        .sheet(isPresented: $showSignUp) {
            SignUpView(showSignUp: $showSignUp)
}
        .alert(authViewModel.error?.localizedDescription ?? "Unknown error", isPresented: $authViewModel.hasError, actions: {Text("OK")})
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView().environmentObject({ () -> AuthViewModel in
//                            let envObj = AuthViewModel()
//                            return envObj
//                        }() )
//        .environmentObject({ () -> StocksViewModel in
//            let envObj = StocksViewModel(email: "test@mail.com",  stocks: Stock.previewStocks)
//                            return envObj
//                        }() )
//    }
//}

