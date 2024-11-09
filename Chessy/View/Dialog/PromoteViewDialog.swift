//
//  PromoteViewDialog.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/11/2024.
//

import SwiftUI

struct PromoteViewDialog: View {
    let viewModel: ChessGameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea() // Làm mờ nền phía sau
            
            HStack (spacing: 10){
                let pieces = [
                    ("queen", "Queen"),
                    ("knight", "Knight"),
                    ("bishop", "Bishop"),
                    ("rook", "Rook")
                ]
                
                ForEach(pieces, id: \.0) { piece in
                    VStack {
                        Image(viewModel.whiteTurn! ? "\(piece.0)-white" : "\(piece.0)-black")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                        
                        Text(piece.1)
                    }
                    .onTapGesture {
                        viewModel.promoteChoice = piece.0
                        viewModel.promote(pawn: viewModel.pawnPromoted!)
                        viewModel.promote = false
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

#Preview {
    PromoteViewDialog(viewModel: ChessGameViewModel())
}
