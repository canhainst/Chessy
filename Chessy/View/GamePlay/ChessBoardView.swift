//
//  ChessBoardView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var viewModel: ChessGameViewModel
    @State private var selectedPiecePosition: (Int, Int)? // Lưu vị trí quân cờ được chọn
    @State private var availableMoves: [(Int, Int)] = [] // Lưu các ô có thể di chuyển
    @State private var pieceDanger: [(Int, Int)] = []

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8) { column in
                        ChessSquareView(viewModel: viewModel, piece: viewModel.getPiece(at: (row, column)),
                                        row: row,
                                        column: column,
                                        isDanger: pieceDanger.contains(where: {$0 == (row, column)}),
                                        isHighlighted: availableMoves.contains(where: { $0 == (row, column) }),
                                        onTap: {
                                            pieceTapped(at: (row, column))
                                        })
                    }
                }
            }
        }
        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
    }

    private func pieceTapped(at position: (Int, Int)) {
        if let selected = selectedPiecePosition, selected == position {
            // Nếu đã chọn quân cờ, bỏ chọn
            selectedPiecePosition = nil
            availableMoves = []
        } else {
            // Nếu chọn quân cờ mới
            if let piece = viewModel.getPiece(at: position) {
                if piece.color == .white && viewModel.whiteTurn! && viewModel.playerColor == .white { // Chỉ cho phép người chơi trắng di chuyển quân cờ trắng
                    selectedPiecePosition = position
                    availableMoves = piece.possibleMoves(on: viewModel.board) // Lấy các ô có thể di chuyển
                } else if piece.color == .black && !viewModel.whiteTurn! && viewModel.playerColor == .black {
                    selectedPiecePosition = position
                    availableMoves = piece.possibleMoves(on: viewModel.board) // Lấy các ô có thể di chuyển
                } else if let selected = selectedPiecePosition, (viewModel.whiteTurn! && piece.color == .black && availableMoves.contains(where: {$0 == position})) || (!viewModel.whiteTurn! && piece.color == .white && availableMoves.contains(where: {$0 == position})) {
                    
                    let cloneBoard = viewModel.simulatorMove(from: selected, to: position)
                    
                    if let oppositePiece = viewModel.checkIfKingInDanger(boardgame: cloneBoard, kingColor: viewModel.playerColor!), !oppositePiece.isEmpty {
                        pieceDanger = oppositePiece
                        pieceDanger.append(viewModel.findKingPosition(board: viewModel.board, kingColor: viewModel.playerColor!)!)
                    } else {
                        pieceDanger = []
                        
                        viewModel.movePiece(from: selected, to: position, control: true) // Di chuyển quân cờ
                        viewModel.deadPieces.append(piece)
                    }
                    selectedPiecePosition = nil
                    availableMoves = [] // Reset các ô có thể di chuyển
                }
            } else if let selected = selectedPiecePosition {
                if availableMoves.contains(where: { $0 == position }) {
                    
                    let cloneBoard = viewModel.simulatorMove(from: selected, to: position)
                    
                    if let oppositePiece = viewModel.checkIfKingInDanger(boardgame: cloneBoard, kingColor: viewModel.playerColor!), !oppositePiece.isEmpty {
                        pieceDanger = oppositePiece
                        pieceDanger.append(viewModel.findKingPosition(board: viewModel.board, kingColor: viewModel.playerColor!)!)
                    } else {
                        pieceDanger = []
                        
                        // Nếu vị trí được chọn là một trong những ô có thể di chuyển
                        viewModel.movePiece(from: selected, to: position, control: true) // Di chuyển quân cờ
                    }
                    
                    selectedPiecePosition = nil
                    availableMoves = [] // Reset các ô có thể di chuyển
                }
            }
        }
    }
}


struct ChessSquareView: View {
    @ObservedObject var viewModel: ChessGameViewModel
    
    var piece: ChessPiece?
    var row: Int
    var column: Int
    var isDanger: Bool
    var isHighlighted: Bool // Thêm thuộc tính này
    var onTap: () -> Void // Thêm closure để xử lý sự kiện tap

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isHighlighted ? Color.green : (isDanger ? Color.red : squareColor(forRow: row, column: column)))
                .frame(width: 45, height: 45)
                .border(isHighlighted ? Color.black : Color.white, width: 0.2)
                .onTapGesture {
                    guard let playerEID = viewModel.playerEID, !playerEID.isEmpty else {
                        return // Không làm gì khi playerEID là nil hoặc rỗng
                    }
                    onTap() // Gọi closure khi playerEID không rỗng
                }
            
            if let piece = piece {
                Image(pieceSymbol(for: piece))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(piece.color == .white ? Color.white : Color.black)
            }
        }
    }

    func squareColor(forRow row: Int, column: Int) -> Color {
        return (row + column) % 2 == 0 ? Color.white : Color(red: 0.854, green: 0.514, blue: 0.349)
    }

    func pieceSymbol(for piece: ChessPiece) -> String {
        guard let playerEID = viewModel.playerEID, !playerEID.isEmpty, viewModel.playerColor != nil else {
            return ""
        }
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
