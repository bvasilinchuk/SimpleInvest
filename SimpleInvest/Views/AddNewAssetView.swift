//
//  AddNewAssetView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import SwiftUI

struct AddNewAssetView: View {
@ObservedObject var viewModel: StocksViewModel
@ObservedObject var searchViewModel: SearchStockViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var searchText: String
    @Binding var isShowingAddNewAsset: Bool
    @State var currentPrice: Double?
    @State var quantity: Double?
    @State var name: String = ""
    @State var ticker: String = ""
    @State var averagePrice: Double?
    @State var isloading = false
    var body: some View {
        NavigationView{
        VStack{
            Form{
                Section{
                TextField("Ticker", text: $ticker)
                        .disabled(true)
                    TextField("Quantity", value: $quantity, format: .number).keyboardType(.numberPad)
                    TextField("Average Price", value: $averagePrice, format: .number).keyboardType(.numberPad)
                }
                Button(action: {
                    print("1. \(String.timestamp())")
                    viewModel.getStockAsync(ticker: ticker, name: name, quantity: quantity ?? 0, averagePrice: averagePrice ?? 0, completion: {
                        searchText = ""
                        searchViewModel.clearList()
                        print("Before dismiss \(String.timestamp())")
    //                        dismiss()
                        print("After dismiss \(String.timestamp())")
                    })
                    print("4. \(String.timestamp())")
                }, label: {
                    if viewModel.isLoading == true{
                        ProgressView()
                    } else {
                    Text("Add")
                    }
                })
                .foregroundColor(.white)
                .progressViewStyle(.circular)
                .listRowBackground(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .center).padding()
            }
            .disabled(isloading == true)

        }
        .navigationTitle("Add stock")
    }
        .onAppear(perform: {            UITabBar.appearance().barTintColor = .black
            UITabBar.appearance().isTranslucent = true})
    }
}

//struct AddNewAssetView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNewAssetView(viewModel: StocksViewModel(), searchViewModel: SearchStockViewModel())
//    }ChildView
//}

