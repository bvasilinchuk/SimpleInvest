//
//  AuthViewModel.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 22.02.2023.
//

import Foundation
import SwiftUI
import FirebaseAuth
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var showMainView = false
    var user: User?
    {
        didSet {
            objectWillChange.send()
        }
    }
    init(){
        listenToAuthState()
    }
    var error: Error?
    @Published var hasError = false
    @Published var isLoading = false
    
    func login(email: String, password: String, completion: @escaping() -> ()) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.error = error
                print(error?.localizedDescription ?? "")
                self.hasError = true
                return
            } else {
                print("success")
                completion()
            }
            self.isLoading = false
        }
        
    }
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showMainView = true
            }
            
        }
    }
    
    func signUp(
        emailAddress: String,
        password: String,
        completion: @escaping() -> ()
    ) {
        isLoading = true
        Auth.auth().createUser(withEmail: emailAddress, password: password) { result, error in
            if let error = error {
                print("an error occured: \(error.localizedDescription)")
                self.error = error
                self.hasError = true
                return
            }
            completion()
            self.isLoading = false
        }
        
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            error = signOutError
            hasError = true
            print("Error signing out: %@", signOutError)
        }
    }
    
    func deleteUser(completion: @escaping ()->() ){
        print("delete user initiated")
        Task{
            do{
                user?.delete(){ error in
                    if let error = error {
                        self.error = error
                        self.hasError = true
                        print("Error deleting user: \(error.localizedDescription)")
                        return
                    } else {
                        print("User deleted successfully!")
                        completion()
                    }
                }
            }
        }
    }
}
