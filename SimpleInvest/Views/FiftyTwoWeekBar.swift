//
//  52weekBar.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 23.04.2023.
//

import SwiftUI

struct StockPriceRangeView: View {
    let currentPrice: Double
    let highestPrice: Double
    let lowestPrice: Double
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment: .bottom) {
                StockPriceBar(currentPrice: currentPrice, highestPrice: highestPrice, lowestPrice: lowestPrice)
                
                Triangle(currentPrice: currentPrice, highestPrice: highestPrice, lowestPrice: lowestPrice, barWidth: geometry.size.width)
                    .fill(Color.gray)
                    .frame(width: 20, height: 10)
                    .padding(.bottom, 15)
            }
            .padding(.horizontal)
        }
    }
}

struct StockPriceBar: View {
    let currentPrice: Double
    let highestPrice: Double
    let lowestPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("52 Week Range")
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                
//                GeometryReader { geometry in
//                    HStack(spacing: 0) {
//                        Rectangle()
//                            .fill(Color.red)
//                            .frame(width: CGFloat((currentPrice - lowestPrice) / (highestPrice - lowestPrice)) * geometry.size.width, height: 8)
//                        
//                        Rectangle()
//                            .fill(Color.green)
//                            .frame(width: CGFloat((highestPrice - currentPrice) / (highestPrice - lowestPrice)) * geometry.size.width, height: 8)
//                    }
////                    .overlay(
////                        Text("\(currentPrice, specifier: "%.2f")")
////                            .font(.caption)
////                            .offset(x: CGFloat((currentPrice - lowestPrice) / (highestPrice - lowestPrice)) * geometry.size.width - 10, y: -20)
////                            .foregroundColor(.gray)
////                    )
//                }
            }
            
            HStack {
                Text("$ \(lowestPrice, specifier: "%.2f")")
                    .bold()
                Spacer()
                Text("$ \(highestPrice, specifier: "%.2f")")
                    .bold()
            }
            .offset(y: 5)
        }
    }
}

struct Triangle: Shape {
    let currentPrice: Double
    let highestPrice: Double
    let lowestPrice: Double
    let barWidth: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: CGFloat(((currentPrice - lowestPrice) / (highestPrice - lowestPrice)) * barWidth)-barWidth/2 , y: 0))
        path.addLine(to: CGPoint(x: (path.currentPoint?.x ?? 0) - 10, y: rect.height))
        path.addLine(to: CGPoint(x: (path.currentPoint?.x ?? 0) + 20, y: rect.height))
        path.addLine(to: CGPoint(x: (path.currentPoint?.x ?? 0) - 10, y: 0))
        return path
    }
}

struct StockPriceRangeView_Previews: PreviewProvider {
    static var previews: some View {
        StockPriceRangeView(currentPrice: 110.0, highestPrice: 120.0, lowestPrice: 60.0)
            .previewLayout(.fixed(width: 320, height: 140))
    }
}
