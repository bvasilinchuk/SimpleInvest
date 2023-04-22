//
//  StockTabView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 20.04.2023.
//

import SwiftUI

struct StockTabView: View {
    var stock: Stock
    @StateObject var chartViewModel: ChartViewModel
    @State private var selection = 0
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
            VStack{HStack{
                Button(action: {dismiss()}, label: {Label("Back", systemImage: "chevron.backward")})
                    .font(.title)
                    .labelStyle(.iconOnly)
                    .padding(.horizontal)
                Spacer()
            }
                HStack{
                    Spacer()
                    Button("Main", action: {withAnimation (.linear){selection = 0}
                    })
                    .fontWeight(selection == 0 ? .bold : .thin)
                    Spacer()
                    Button("News", action: {withAnimation(.linear){selection = 1}
                    })
                    .fontWeight(selection == 1 ? .bold : .light)
                    Spacer()
                    Button("Intrinsic value", action: {withAnimation(.linear){selection = 2}
                    })
                    .fontWeight(selection == 2 ? .bold : .light)
                    Spacer()
                }
                
                .padding()
            }
            .foregroundColor(.primary)
            TabView(selection: $selection) {
                StockView(stock: stock, chartViewModel: chartViewModel).tag(0)
                StockNewsView(stock: stock).tag(1)
                Text("Third tab").tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct StockTabView_Previews: PreviewProvider {
    static var previews: some View {
        StockTabView(stock: Stock.previewStocks.first!, chartViewModel: ChartViewModel(stock: Stock.previewStocks.first!))
    }
}
