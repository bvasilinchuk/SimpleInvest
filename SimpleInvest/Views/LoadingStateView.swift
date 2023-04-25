//
//  LoadingStateView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 23.04.2023.
//

import SwiftUI

struct LoadingStateView: View {
    
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView()
    }
}
