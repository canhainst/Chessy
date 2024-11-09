//
//  InputRoomCodeViewDialog.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/11/2024.
//

import SwiftUI
import FirebaseAuth

struct InputRoomCodeViewDialog: View {
    let currentUserID: String
    @Binding var isShow: Bool
    @Binding var isPlayGame: Bool
    @ObservedObject var viewModel: ChessGameViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if isShow {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea() // Blur the background
            
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShow = false
                        }) {
                            Image(systemName: "x.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                    }
                    
                    TextField("Room code 6 digits", text: $viewModel.roomCode)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(colorScheme == .light ? Color(.systemGray6) : Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    HStack {
                        Button {
                            let newMatch = MatchModel(gameID: UUID(), roomID: viewModel.roomCode, playerID: [currentUserID, nil], movesPieces: [], playerWinID: nil, host: currentUserID, whitePiece: nil)
                            
                            MatchModel.insertNewGame(matchModel: newMatch)
                            
                            isShow = false
                            isPlayGame = true
                            
                        } label: {
                            Text("Create a room")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 160)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.roomCode.count != 6) // Disable if code is not 6 digits
                        
                        Button {
                            MatchModel.joinGame(playerID: currentUserID, roomID: viewModel.roomCode)
                            
                            isShow = false
                            isPlayGame = true
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
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}
