//
//  SearchBarView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 06.02.2023.
//

import SwiftUI
//это нужно для обновлений при добавлении новых символов
import Combine

struct SearchBarView: View {
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch // 1
    @EnvironmentObject var stocksViewModel: StocksViewModel
    @State private var showDropdown = false
    @State var searchText = ""
    @EnvironmentObject var searchViewModel: SearchStockViewModel
    @State var isShowingAddNewAsset = false
    private let textSubject = PassthroughSubject<String, Never>()
    var body: some View {

        NavigationView{

        VStack{
                List(searchViewModel.matchedStocks) { result in
                    NavigationLink( destination: {
                        AddNewAssetView(viewModel: stocksViewModel, searchViewModel: searchViewModel, searchText: $searchText, isShowingAddNewAsset: $isShowingAddNewAsset, name: result.name ?? "no value", ticker: result.symbol ?? "no_value").navigationBarTitleDisplayMode(.inline)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
        .onReceive(textSubject.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main).eraseToAnyPublisher()) { value in
            searchViewModel.getStockAsync(ticker: value, completion: {showDropdown = true})
        }
        .onChange(of: searchText) { value in
                        self.textSubject.send(value)
                    }
        }

        
    }
    


struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
