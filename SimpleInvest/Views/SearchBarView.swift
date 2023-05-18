//
//  SearchBarView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import SwiftUI
import Combine

struct SearchBarView: View {
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch // 1
    @EnvironmentObject var stocksViewModel: StocksViewModel
    @EnvironmentObject var searchViewModel: SearchStockViewModel
    @State var isShowingAddNewAsset = false
    private let textSubject = PassthroughSubject<String, Never>()
    var body: some View {
            NavigationView{
                
                VStack{
                    SearchBar(searchText: $searchViewModel.searchString)
                        .padding()
                    List(searchViewModel.matchedStocks) { result in
                        NavigationLink( destination: {
                            AddNewAssetView(viewModel: stocksViewModel, searchViewModel: searchViewModel, isShowingAddNewAsset: $isShowingAddNewAsset, name: result.name ?? "no value", ticker: result.symbol ?? "no_value").navigationBarTitleDisplayMode(.inline)
                        },
                                        label:{
                            ListRowView(name: result.name ?? "", ticker: result.symbol ?? "", placement: .search)
                        })}
                    .frame(minHeight: 0, maxHeight: .infinity)
                }
                .overlay(Group{
                    if searchViewModel.matchedStocks.isEmpty {
                        VStack{
                            Text("Start by typing Company name or ticker")
                                .multilineTextAlignment(.center)
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .font(.title2)
                                .padding()
                        }
                    }})
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationTitle("Search for stock")
            .disableAutocorrection(true)
        }
        
        
}

struct SearchBar: View {
    @Binding var searchText: String
    @State private var isEditing: Bool = false

    var body: some View {
        HStack {
            TextField("Search", text: $searchText, onEditingChanged: { isEditing in
                self.isEditing = isEditing
            })
            .disableAutocorrection(true)
            .padding(.vertical, 8)
            .padding(.leading, 30)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Spacer()
                }
            )
            .onTapGesture {
                self.isEditing = true
            }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                })
            }
        }
    }
}



//struct SearchBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBarView().environmentObject({ () -> SearchStockViewModel in
//            let envObj = SearchStockViewModel(matchedStocks: [SearchStock(shortname: "Apple", type: nil, symbol: "AAPL", name: "Apple")])
//                            return envObj
//                        }() )
//        .environmentObject({ () -> StocksViewModel in
//            let envObj = StocksViewModel(email: "test@mail.com",  stocks: Stock.previewStocks)
//                            return envObj
//                        }() )
//    }
//}

