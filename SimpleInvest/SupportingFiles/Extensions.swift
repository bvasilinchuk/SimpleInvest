//
//  Extensions.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 28.02.2023.
//

import Foundation
import SwiftUI

// Добавляем функции к String:
//timestamp() для удобного вывода времени в консоль

extension String {
    static func timestamp() -> String {
        let dateFMT = DateFormatter()
        dateFMT.locale = Locale(identifier: "en_US_POSIX")
        dateFMT.dateFormat = "yyyyMMdd'T'HHmmss.SSSS"
        let now = Date()

        return String(format: "%@", dateFMT.string(from: now))
    }
}

struct LossProfitColor: ViewModifier {
    let value: Double
    
    func body(content: Content) -> some View {
        if value > 0{
            content.foregroundColor(.green)
        } else if value == 0 {
            content
        } else{
            content.foregroundColor(.red)
        }
    }
}

extension Text {
    func lossProfitColor(value: Double) -> some View {
        self.modifier(LossProfitColor(value: value))
    }
}

struct StandardButtonStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.headline)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .progressViewStyle(.circular)
                            .cornerRadius(10)
                            .padding()
        }
}
