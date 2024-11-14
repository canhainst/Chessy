//
//  ChessyHomeView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI
import FirebaseAuth

struct ChessyHomeView: View {
    var currentUserID: String
    @ObservedObject var viewModel = ChessGameViewModel()
    @State private var showInputCodeDialog = false
    @State private var playGame = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Play Chess Online on the #1 Application")
                    .font(.title)
                
                Text("100 Games Today")
                Text("11 Playing Now")
                
                Button {
                } label: {
                    Text("Find match (Ranked)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                Button {
                    showInputCodeDialog = true
                } label: {
                    Text("Play with friend")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            
            InputRoomCodeViewDialog(currentUserID: currentUserID, isShow: $showInputCodeDialog, isPlayGame: $playGame, viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $playGame) {
            GameplayView(viewModel: viewModel, playGame: .constant(true))
        }
    }
}

#Preview {
    ChessyHomeView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
