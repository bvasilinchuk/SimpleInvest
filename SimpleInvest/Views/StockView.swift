//
//  StockView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 11.03.2023.
//

import SwiftUI

struct StockView: View {
    var stock: Stock
    @ObservedObject var chartViewModel: ChartViewModel
    @State var isExpanded = false
    @State var selectedRange: ChartRange = .oneDay
    var body: some View {
        VStack{
            ZStack{
                HStack{
                    VStack{
                        Text(stock.name)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .truncationMode(.tail)
                            .lineLimit(1)
                        Text(stock.ticker)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.frame(maxWidth: UIScreen.main.bounds.width / 2)
                    Spacer()
                    VStack{
                        Text("$" + stock.currentPriceText)
                            .font(.title3.bold())
                        Text("\(stock.averageProfitCash ?? 0>0 ? "+":"")\(stock.averageProfitCash ?? 0, specifier: "%.2f")$ · \(stock.averageProfitPercent ?? 0, specifier: "%.2f")%")
                            .lossProfitColor(value: stock.averageProfitCash ?? 0)
                            .font(.caption)
                    }
                }
                .opacity(chartViewModel.selectedXOpacity)
                VStack{
                    Text(chartViewModel.selectedXDateAndPriceText?.date ?? "")
                        .font(.caption)
                    Text(chartViewModel.selectedXDateAndPriceText?.price ?? "")
                        .font(.title3.bold())
                }
            }
            .padding()
            
            ScrollView{
                chartView.frame(minHeight: 220)
                    .padding()
                
                DateRangePickerView(selectedRange: $chartViewModel.selectedRange)
                Spacer()
                Divider()
                StockPriceRangeView(currentPrice: stock.currentPrice ?? 0, highestPrice: stock.fiftyTwoWeekHigh ?? 0, lowestPrice: stock.fiftyTwoWeekLow ?? 0)
                    .frame(minHeight: UIScreen.main.bounds.height/10)
                    .padding()
                MarketDataView(stock: stock)
            }
        }
        .task(id: chartViewModel.selectedRange) {
            await chartViewModel.fetchData()
        }
    }
    @ViewBuilder
    private var chartView: some View{
        switch chartViewModel.fetchPhase {
        case .fetching: ProgressView()
        case .success(let data): ChartView(data: data, chartViewModel: chartViewModel)
        case .failure(let error):
            Text(error.localizedDescription)
        default: EmptyView()
        }
    }
}




struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        StockView(stock: Stock.previewStocks.first!, chartViewModel: ChartViewModel(stock: Stock.previewStocks.first!))
    }
}



struct DisclosureContainerView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
}
