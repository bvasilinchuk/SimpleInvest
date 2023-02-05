//
//  SignUpView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 19.02.2023.
//

import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Binding var showSignUp: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var stocksViewModel: StocksViewModel
    
    var body: some View {
        VStack {
            Spacer()
//            TextField("Name", text: $name)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
//            SecureField("Confirm Password", text: $confirmPassword)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
            Button(action: {
                authViewModel.signUp(emailAddress: email, password: password, completion: {stocksViewModel.email = authViewModel.user?.email ?? ""})
            }, label: {
                if authViewModel.isLoading{
                    ProgressView()
                } else{
                    Text("Sign up")
                }
            })
            .buttonStyle(StandardButtonStyle())
            Spacer()
            HStack {
                Text("Already have an account?")
                Button(action: {
                    showSignUp = false
                }) {
                    Text("Login")
                }
            }
        }
        .padding()
        .alert(authViewModel.error?.localizedDescription ?? "Unknown error", isPresented: $authViewModel.hasError, actions: {Text("OK")})
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
