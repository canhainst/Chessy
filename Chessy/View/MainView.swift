//
//  ContentView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 03/06/2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else if viewModel.isSignedIn, !viewModel.currentUserID.isEmpty {
                ChessyView(currentUserID: viewModel.currentUserID)
            } else {
                LoginView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                showSplash = false
            }
        }
    }
}

#Preview {
    MainView()
}
