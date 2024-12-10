//
//  GameplayView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import SwiftUI

struct GameplayView: View {
    let roomCode: String
    @ObservedObject var viewModel: ChessGameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(roomCode: String) {
        self.roomCode = roomCode
        self.viewModel = ChessGameViewModel(roomID: roomCode)
    }
    
    var body: some View {
        if let user = viewModel.player {
            ZStack {
                VStack (spacing: 0) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.black)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                                MatchModel.exitGame(playerID: viewModel.playerID, roomID: viewModel.roomCode)
                                viewModel.whiteTurn = nil
                            }
                        
                        Spacer()
                        
                        Text("Room Code: \(viewModel.roomCode)")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if let userE = viewModel.playerE {
                        HStack (alignment: .top){
                            HStack (alignment: .top) {
                                AvatarView(avatarLink: userE.avatar ?? "", width: 50, height: 50)
                                    .frame(alignment: .leading)
                                
                                VStack (alignment: .leading, spacing: 0) {
                                    Text(userE.name)
                                        .foregroundColor(.black)
                                    HStack {
                                        AsyncImage(url: URL(string: userE.nation.flags.png)) { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                 .frame(width: 30)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        Text(viewModel.isHost == false ? "(Host)" : "")
                                            .foregroundColor(.black)
                                    }
                                    Button {
                                        if viewModel.isSentRequest {
                                            // recall
                                            User.recallRequest(userID: viewModel.playerID, deleteID: viewModel.playerEID!)
                                            User.deleteRequest(userID: viewModel.playerEID!, deleteID: viewModel.playerID)
                                        } else if !viewModel.isAddedFriend {
                                            // add friend
                                            User.sendRequest(userID: viewModel.playerID, newRequestID: viewModel.playerEID!)
                                            User.addRequest(userID: viewModel.playerEID!, newRequestID: viewModel.playerID)
                                        }
                                    } label: {
                                        HStack {
                                            if !viewModel.isAddedFriend && !viewModel.isSentRequest {
                                                Image(systemName: "plus")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                            
                                            Text(viewModel.isAddedFriend ? "Friend" : (viewModel.isSentRequest ? "Recall" : "Add friend"))
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                            
                                            if viewModel.isSentRequest {
                                                Image(systemName: "arrow.forward")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                            
                                            if viewModel.isAddedFriend {
                                                Image(systemName: "checkmark")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                    }
                                    .disabled(viewModel.isAddedFriend)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .padding(.top, 3)
                                }
                            }
                            .fixedSize()
                            .padding()
                            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
                            .onAppear {
                                viewModel.listenFriendCheck(userID: viewModel.playerID, friend: viewModel.playerEID!)
                                viewModel.listenSendRequest(userID: viewModel.playerID, friend: viewModel.playerEID!)
                            }
                                            
                            if !viewModel.deadPieces.isEmpty {
                                getDeadPiecesImage(for: viewModel.playerColor! == .white ? .black : .white)
                            }
                            
                            Spacer()
                        }
                        .padding() // Khoảng đệm xung quanh
                        
                        if viewModel.whiteTurn != nil {
                            Text("\(userE.name)'s turn")
                                .font(.headline)
                                .padding()
                                .foregroundColor(((viewModel.whiteTurn! && viewModel.playerColor == .white) || (!viewModel.whiteTurn! && viewModel.playerColor == .black)) ? .clear : .black)
                        }
                    } else {
                        Text("Wait for your opponent")
                            .padding(.top)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    ChessBoardView(viewModel: viewModel)
                    
                    Spacer()
                    
                    if viewModel.whiteTurn != nil {
                        Text("\(user.name)'s turn")
                            .font(.headline)
                            .padding()
                            .foregroundColor((viewModel.whiteTurn! && viewModel.playerColor == .white) || (!viewModel.whiteTurn! && viewModel.playerColor == .black) ? .black : .clear)
                    }
                    
                    HStack (alignment: .top) {
                        Spacer()
                        
                        if !viewModel.deadPieces.isEmpty {
                            getDeadPiecesImage(for: viewModel.playerColor!)
                        }
                        
                        HStack (alignment: .top) {
                            VStack (alignment: .trailing, spacing: 0) {
                                Text(user.name)
                                    .foregroundColor(.black)
                                HStack {
                                    Text(viewModel.isHost == true ? "(Host)" : "")
                                        .foregroundColor(.black)
                                    AsyncImage(url: URL(string: user.nation.flags.png)) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                             .frame(width: 30)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            
                            AvatarView(avatarLink: user.avatar ?? "", width: 50, height: 50)
                                .frame(alignment: .trailing)
                        }
                        .fixedSize()
                        .padding()
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
                    }
                    .padding() // Khoảng đệm xung quanh
                }
                .background(.white)
                
                if viewModel.isFriendRequest && viewModel.playerE != nil {
                    RequestAddFriend(name: viewModel.playerE!.name, viewModel: viewModel)
                        .offset(x: -70, y: 250)
                }
                
                if viewModel.playerE != nil {
                    GameStartDialogView(avatarE: viewModel.playerE?.avatar ?? "", viewModel: viewModel)
                }
                
                if viewModel.promote {
                    PromoteViewDialog(viewModel: viewModel)
                }
                
                if viewModel.showResult {
                    if viewModel.winner == viewModel.playerID {
                        GameResultDialogView(result: 1, roomID: viewModel.roomCode, showResult: $viewModel.showResult, rematchMsg: $viewModel.rematchMsg)
                    } else if viewModel.winner == viewModel.playerEID {
                        GameResultDialogView(result: 0, roomID: viewModel.roomCode, showResult: $viewModel.showResult, rematchMsg: $viewModel.rematchMsg)
                    } else if viewModel.winner == "draw" {
                        GameResultDialogView(result: 2, roomID: viewModel.roomCode, showResult: $viewModel.showResult, rematchMsg: $viewModel.rematchMsg)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.listenForGameChanges(roomCode: viewModel.roomCode)
            }
        }
    }
        
    func getDeadPiecesImage(for color: PlayerColor) -> some View {
        let pieces = viewModel.deadPieces.compactMap { $0 }.filter { $0.color != color }
        let chunkedPieces = pieces.chunked(into: 6)
        
        return VStack {
            ForEach(0..<chunkedPieces.count, id: \.self) { i in
                HStack {
                    ForEach(0..<chunkedPieces[i].count, id: \.self) { j in
                        let piece = chunkedPieces[i][j]
                        Image(pieceSymbol(for: piece))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }
                }
            }
        }
        .fixedSize()
        .frame(alignment: color == .white ? .leading : .trailing)
    }
    
    func pieceSymbol(for piece: ChessPiece) -> String {
        switch piece {
        case is Pawn: return piece.color == .white ? "pawn-white" : "pawn-black"
        case is Knight: return piece.color == .white ? "knight-white" : "knight-black"
        case is Bishop: return piece.color == .white ? "bishop-white" : "bishop-black"
        case is Rook: return piece.color == .white ? "rook-white" : "rook-black"
        case is Queen: return piece.color == .white ? "queen-white" : "queen-black"
        case is King: return piece.color == .white ? "king-white" : "king-black"
        default: return ""
        }
    }
}

#Preview {
    GameplayView(roomCode: "123456")
}
