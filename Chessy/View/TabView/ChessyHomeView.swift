//
//  ChessyHomeView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyHomeView: View {
    var currentUserID: String
    @ObservedObject var viewModel = ChessGameViewModel()
    @State private var showPlayWithFriendDialog = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                VStack {
                    Text("Play Chess Online on the #1 Application")
                        .font(.title)
                    
                    Text("100 Games Today")
                    Text("11 Playing Now")
                    
                    Button {
                    } label: {
                        Text("Find match")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button {
                        showPlayWithFriendDialog = true
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
                
                if showPlayWithFriendDialog {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea() // Làm mờ nền phía sau
                    
                    VStack (spacing: 20){
                        HStack {
                            Spacer()
                            Button(action: {
                                showPlayWithFriendDialog = false
                            }) {
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        }
                        
                        TextField("Room code", text: $viewModel.roomCode)
                            .keyboardType(.numberPad) // Hiển thị bàn phím chỉ có số
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        HStack {
                            Button {
                                showPlayWithFriendDialog = false
                            } label: {
                                Text("Create a room")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 160)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button {
                                showPlayWithFriendDialog = false
                            } label: {
                                Text("Join a room")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 160)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ChessyHomeView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
