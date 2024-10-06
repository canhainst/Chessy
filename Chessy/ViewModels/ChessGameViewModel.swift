//
//  ChessGameViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class ChessGameViewModel: ObservableObject {
    @Published private(set) var board: [[ChessPiece?]]
    @Published private(set) var whiteTurn: Bool
    
    init() {
        self.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        self.whiteTurn = true
        setupBoard()
    }

    private func setupBoard() {
        // Khởi tạo bàn cờ với các quân cờ
        for i in 0..<8 {
            board[6][i] = Pawn(color: .white, position: (6, i)) // Quân cờ trắng
            board[1][i] = Pawn(color: .black, position: (1, i)) // Quân cờ đen
        }
        // Đặt các quân cờ khác cho trắng
        board[7][0] = Rook(color: .white, position: (7, 0))
        board[7][7] = Rook(color: .white, position: (7, 7))
        board[7][1] = Knight(color: .white, position: (7, 1))
        board[7][6] = Knight(color: .white, position: (7, 6))
        board[7][2] = Bishop(color: .white, position: (7, 2))
        board[7][5] = Bishop(color: .white, position: (7, 5))
        board[7][3] = Queen(color: .white, position: (7, 3))
        board[7][4] = King(color: .white, position: (7, 4))
        
        // Đặt các quân cờ khác cho đen
        board[0][0] = Rook(color: .black, position: (0, 0))
        board[0][7] = Rook(color: .black, position: (0, 7))
        board[0][1] = Knight(color: .black, position: (0, 1))
        board[0][6] = Knight(color: .black, position: (0, 6))
        board[0][2] = Bishop(color: .black, position: (0, 2))
        board[0][5] = Bishop(color: .black, position: (0, 5))
        board[0][3] = Queen(color: .black, position: (0, 3))
        board[0][4] = King(color: .black, position: (0, 4))
    }

    func movePiece(from start: (Int, Int), to end: (Int, Int)) {
        guard let piece = board[start.0][start.1] else { return }
        
        // Kiểm tra nếu vị trí đích có quân cờ của cùng màu không
        if let targetPiece = board[end.0][end.1], targetPiece.color == piece.color {
            return // Không cho phép di chuyển nếu đích có quân cờ cùng màu
        }

        // Di chuyển quân cờ
        board[end.0][end.1] = piece
        board[start.0][start.1] = nil
        piece.position = end
        
        toggleTurn()
    }
    
    func toggleTurn() {
        whiteTurn.toggle()
    }

    func getPiece(at position: (Int, Int)) -> ChessPiece? {
        return board[position.0][position.1]
    }
    
    func resetGame() {
        setupBoard()
    }
}
