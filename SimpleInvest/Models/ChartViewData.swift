//
//  ChartViewData.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 15.04.2023.
//

import Foundation
import SwiftUI

struct ChartViewData: Identifiable{
    let id = UUID()
    let xAxisData: ChartAxisData
    let yAxisData: ChartAxisData
    let items: [ChartViewItem]
    let lineColor: Color
}

struct ChartViewItem: Identifiable{
    let id = UUID()
    let timestamp: Date
    let value: Double
}

struct ChartAxisData{
    let axisStart: Double
    let axisEnd: Double
    let strideBy: Double
    let map: [String: String]
}
