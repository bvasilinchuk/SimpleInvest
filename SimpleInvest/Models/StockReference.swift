//
//  StockReference.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 22.04.2023.
//

import Foundation

struct StockReference: Identifiable, Hashable {
    var id = UUID()
    var firebaseId = ""
    var name: String
    let ticker: String
    var averagePrice: Double
    var quantity: Int
}
