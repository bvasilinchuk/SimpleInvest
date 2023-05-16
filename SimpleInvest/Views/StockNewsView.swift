//
//  StockNewsView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 21.04.2023.
//

import SwiftUI
import SafariServices

struct StockNewsView: View {
    private let selectedValueDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
@EnvironmentObject var searchViewMidel: SearchStockViewModel
    var stock: Stock
    var body: some View {
        ScrollView{
            ForEach(searchViewMidel.matchedNews){item in
                if let publisher = item.publisher, let time = item.providerPublishTime, let title = item.title, let link = item.link, let imageUrl = item.thumbnail?.resolutions.last!.url {
                    Link(destination: URL(string: link)!, label: {
                        HStack{
                            AsyncImage(url: URL(string: imageUrl), scale: 1.5)
                                .frame(maxWidth: 93, maxHeight: 93)
                                .cornerRadius(10)
                            VStack(alignment: .leading){
                                Text(title)
                                    .lineLimit(3).truncationMode(.tail)
                                    .multilineTextAlignment(.leading)
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                Spacer()
                                HStack{
                                        Text(publisher)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                        Text(selectedValueDateFormatter.string(from: time))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        Divider()
                    })

                }
            }
            }
        .onAppear(perform: {searchViewMidel.getNewsAsync(ticker: stock.ticker)})
        .onDisappear(perform: {searchViewMidel.matchedNews.removeAll()})
    }
}

struct StockNewsView_Previews: PreviewProvider {
    static var previews: some View {
        StockNewsView(stock: Stock.previewStocks.first!)
    }
}
