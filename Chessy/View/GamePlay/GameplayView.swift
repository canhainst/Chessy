//
//  GameplayView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import SwiftUI

struct GameplayView: View {
    @ObservedObject var viewModel = ChessGameViewModel()
    @Binding var playGame: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var avatar = "https://scontent.fsgn5-15.fna.fbcdn.net/v/t39.30808-1/329403231_474295524745893_3398994404525045455_n.jpg?stp=dst-jpg_s320x320&_nc_cat=101&ccb=1-7&_nc_sid=0ecb9b&_nc_ohc=KWc8e4ajb_kQ7kNvgFKv9O1&_nc_ht=scontent.fsgn5-15.fna&_nc_gid=AsElcq77z_KMcshyn3x5587&oh=00_AYCnMSrtUC7eOKxmjZbybn9fTggSMOi9sk27Ia68sgrbDw&oe=670BE6EB"
    
    @State private var avatarE = "https://scontent.fsgn5-9.fna.fbcdn.net/v/t39.30808-1/358969835_1295627944715660_3629977290591665492_n.jpg?stp=dst-jpg_s480x480&_nc_cat=102&ccb=1-7&_nc_sid=0ecb9b&_nc_ohc=gtW1Gt2_1cEQ7kNvgEnDCQP&_nc_ht=scontent.fsgn5-9.fna&_nc_gid=Az0sZmRT_Wh3QXNYMd7ySUv&oh=00_AYDJX-tKbFz6FsfAR6mlomKEKlcLMRU44mNnYEVj-cM5yQ&oe=67064B0C"
    
    var body: some View {
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
                
                if (viewModel.playerE == nil) {
                    Text("Wait for your opponent")
                        .padding(.top)
                        .foregroundColor(.black)
                } else {
                    HStack (alignment: .top){
                        HStack (alignment: .top) {
                            AvatarView(avatarLink: avatarE, width: 50, height: 50)
                                .frame(alignment: .leading)
                            
                            VStack (alignment: .leading, spacing: 0) {
                                Text(viewModel.playerE!.name)
                                    .foregroundColor(.black)
                                HStack {
                                    Image("VN")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit) // Giữ tỷ lệ ảnh
                                        .frame(width: 30)
                                    Text(viewModel.isHost == false ? "(Host)" : "")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .fixedSize()
                        .padding()
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
                                        
                        if !viewModel.deadPieces.isEmpty {
                            getDeadPiecesImage(for: viewModel.playerColor! == .white ? .black : .white)
                        }
                        
                        Spacer()
                    }
                    .padding() // Khoảng đệm xung quanh
                    
                    if viewModel.whiteTurn != nil {
                        Text("\(viewModel.playerE?.name ?? "")'s turn")
                            .font(.headline)
                            .padding()
                            .foregroundColor(((viewModel.whiteTurn! && viewModel.playerColor == .white) || (!viewModel.whiteTurn! && viewModel.playerColor == .black)) ? .clear : .black)
                    }
                }
                
                ChessBoardView(viewModel: viewModel)
                    .onAppear {
                        viewModel.listenForGameChanges(roomCode: viewModel.roomCode)
                    }
                
                if viewModel.whiteTurn != nil {
                    Text("\(viewModel.player?.name ?? "")'s turn")
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
                            Text(viewModel.player!.name)
                                .foregroundColor(.black)
                            HStack {
                                Text(viewModel.isHost == true ? "(Host)" : "")
                                    .foregroundColor(.black)
                                Image("VN")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Giữ tỷ lệ ảnh
                                    .frame(width: 30)
                            }
                        }
                        
                        AvatarView(avatarLink: avatar, width: 50, height: 50)
                            .frame(alignment: .trailing)
                    }
                    .fixedSize()
                    .padding()
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
                }
                .padding() // Khoảng đệm xung quanh
            }
            .background(.white)
            
            if viewModel.playerE != nil {
                GameStartDialogView(avatarE: avatarE, viewModel: viewModel)
            }
            
            if viewModel.promote {
                PromoteViewDialog(viewModel: viewModel)
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
    GameplayView(playGame: .constant(true))
}
