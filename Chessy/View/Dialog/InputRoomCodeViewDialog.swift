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
    
    @State private var messTitle: String = ""
    @State private var message: String = ""
    @State private var isAlertShown = false
    
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
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    HStack {
                        Button {
                            let newMatch = MatchModel(gameID: UUID(), roomID: viewModel.roomCode, playerID: [currentUserID, nil], pieceMoves: [], playerWinID: nil, host: currentUserID, whitePiece: nil)
                            
                            MatchModel.insertNewGame(matchModel: newMatch) { success in
                                if success {
                                    isShow = false
                                    isPlayGame = true
                                } else {
                                    //alert dialog
                                    messTitle = "Room Code Exists"
                                    message = "The room code you entered already exists. Please try a different code."
                                    isAlertShown = true
                                }
                            }
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
                            MatchModel.joinGame(playerID: currentUserID, roomID: viewModel.roomCode) { errorCode in
                                switch errorCode {
                                case 0:
                                    isShow = false
                                    isPlayGame = true
                                case 1:
                                    messTitle = "Error"
                                    message = "RoomID not found."
                                    isAlertShown = true
                                case 2:
                                    messTitle = "Error"
                                    message = "Room is full for 2 players."
                                    isAlertShown = true
                                case 3:
                                    messTitle = "Error"
                                    message = "An error occurred while joining the game.."
                                    isAlertShown = true
                                default:
                                    messTitle = "Error"
                                    message = "Unknown error code."
                                    isAlertShown = true
                                }
                            }
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
                .alert(isPresented: $isAlertShown) { // Sử dụng alert khi isAlertShown là true
                    Alert(
                        title: Text(messTitle),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}
