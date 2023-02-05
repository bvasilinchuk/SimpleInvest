//
//  ListRowView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 05.02.2023.
//

import SwiftUI

struct ListRowView: View {
    var name: String
    var price: Double
    var totalPrice: Double
    var ticker: String
    var quantity: Double
    var profitCash: Double
    var profitPercent: Double
    var body: some View {
        HStack{
//            AsyncImage(url: URL(string: "https://simpleinvest.online/logo/\(ticker)"))
            VStack{
                Text("\(name)")
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .truncationMode(.tail)
                    .lineLimit(1)
                Text("\(Int(quantity)) · \(price, specifier: "%.2f") $").font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            VStack{
                Text("\(totalPrice, specifier: "%.2f") $")
                    .font(.callout.bold())
                    Text("\(profitCash>0 ? "+":"")\(profitCash, specifier: "%.2f")$ · \(profitPercent, specifier: "%.2f")%")
                    .font(.caption).lossProfitColor(value: profitCash)
            }
        }
        .padding(.vertical, 5)

}

//struct ListRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListRowView()
//    }
//}
}
