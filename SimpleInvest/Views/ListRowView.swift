//
//  ListRowView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 05.02.2023.
//

import SwiftUI

struct ListRowView: View {
    var name: String
    var price: Double?
    var totalPrice: Double?
    var ticker: String
    var quantity: Double?
    var profitCash: Double?
    var profitPercent: Double?
    let placement: Place
    enum Place {
        case home
        case search
    }
    var body: some View {
        HStack{
//            AsyncImage(url: URL(string: "https://simpleinvest.online/logo/\(ticker)"))
            VStack{
                Text("\(name)")
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .truncationMode(.tail)
                    .lineLimit(1)
                if placement == .home{
                    Text("\(Int(quantity ?? 0)) · \(price ?? 0, specifier: "%.2f") $")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else{Text(ticker).font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)}
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if placement == .home{
                if let profitCash = profitCash{
                    VStack{
                        Text("\(totalPrice ?? 0, specifier: "%.2f") $")
                            .font(.callout.bold())
                        Text("\(profitCash>0 ? "+":"")\(profitCash, specifier: "%.2f")$ · \(profitPercent ?? 0, specifier: "%.2f")%")
                            .font(.caption).lossProfitColor(value: profitCash)
                    }
                }
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
