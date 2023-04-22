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
        ScrollView{
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
                            Text("\(stock.currentPrice, specifier: "%.2f") $")
                                .font(.title3.bold())
                            Text("\(stock.averageProfitCash>0 ? "+":"")\(stock.averageProfitCash, specifier: "%.2f")$ · \(stock.averageProfitPercent, specifier: "%.2f")%")
                                .lossProfitColor(value: stock.averageProfitCash)
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
                
                chartView.frame(minHeight: 220)
                    .padding()
            
//                if let chart = chartViewModel.chart{
//                    ChartView(data: chart, chartViewModel: chartViewModel)
//                        .padding()
//                }
                DateRangePickerView(selectedRange: $chartViewModel.selectedRange)
                DisclosureContainerView{
                    DisclosureGroup("Company description", isExpanded: $isExpanded) {
                        Text(stock.description)
                            .font(.callout)
                            .padding()
                    }
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            self.isExpanded.toggle()
                        }
                    }
                }
                Group{
                    HStack{
                        Text("Yearly dividend:")
                        Spacer()
                        Text("\(stock.dividendsPastYear, specifier: "%.2f") $")
                            .bold()
                    }
                    HStack{
                        Text("Dividend yield:")
                        Spacer()
                        Text("\(stock.dividendYield*100, specifier: "%.2f") %")
                            .bold()
                    }
                    HStack{
                        Text("Market Cap:")
                        Spacer()
                        Text("\(stock.marketCap, specifier: "%.2f") $")
                            .bold()
                    }
                    HStack{
                        Text("Market Cap text")
                        Spacer()
                        Text(stock.marketCapText)
                            .bold()
                    }
                    HStack{
                        Text("P/E:")
                        Spacer()
                        Text("\(stock.peRatio, specifier: "%.2f")")
                            .bold()
                    }
                    HStack{
                        Text("52week low")
                        Spacer()
                        Text("\(stock.fiftyTwoWeekLow, specifier: "%.2f")")
                            .bold()
                    }
                    HStack{
                        Text("52week high")
                        Spacer()
                        Text("\(stock.fiftyTwoWeekHigh, specifier: "%.2f")")
                            .bold()
                    }
                }
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                Spacer()
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
