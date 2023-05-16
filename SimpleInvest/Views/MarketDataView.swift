//
//  MarketDataView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 24.04.2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    let stock: Stock
    private let selectedValueDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    var body: some View {
                HStack {
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Market Cap")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(stock.marketCapText ?? "-")
                                .bold()
                        }
                        .padding(.bottom, 5)
                        VStack(alignment: .leading){
                            Text("P/E (TTM)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(stock.peRatio ?? "-")
                                .bold()
                        }
                        .padding(.bottom, 5)
                            VStack(alignment: .leading){
                                Text("EPS")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text(stock.epsText ?? "-")
                                    .bold()
                            }
                            .padding(.bottom, 5)
                            VStack(alignment: .leading){
                                Text("Beta")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text(stock.beta ?? "-")
                                    .bold()
                            }
                            .padding(.bottom, 5)
                    }
                    .frame(width: UIScreen.main.bounds.width/2.2)
                    Spacer()
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Dividend Yield")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text("\((stock.dividendYield ?? 0)*100, specifier: "%.2f") %")
                                .bold()
                        }
                        .padding(.bottom, 5)
                        VStack(alignment: .leading){
                            Text("Annual Dividend")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(stock.divRatePastYearText ?? "-")
                                .bold()
                        }
                        .padding(.bottom, 5)
                        VStack(alignment: .leading){
                            Text("Dividend Date")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            if let date = stock.dividendDate{
                                Text(selectedValueDateFormatter.string(from: date))
                                    .bold()
                            } else{
                                Text("-")
                                    .bold()
                            }}
                            .padding(.bottom, 5)
                        VStack(alignment: .leading){
                            Text("Price/Book Value")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(stock.priceToBook ?? "-")
                                .bold()
                        }
                        .padding(.bottom, 5)
                    }
                    .frame(width: UIScreen.main.bounds.width/2.2)
                }
    }
}





struct MarketDataView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(stock: Stock.previewStocks.first!)
    }
}
