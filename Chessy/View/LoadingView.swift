//
//  LoadingView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 22/06/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        LottieView(filename: "loading.json")
            .frame(height: 150)
    }
}

#Preview {
    LoadingView()
}
