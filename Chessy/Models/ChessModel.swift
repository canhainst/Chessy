//
//  ChessModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

enum PlayerColor {
    case white, black
}

class ChessPiece {
    let color: PlayerColor
    var position: (Int, Int)

    init(color: PlayerColor, position: (Int, Int)) {
        self.color = color
        self.position = position
    }

    func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        return []
    }
}

struct ChessBoard {
    var pieces: [[ChessPiece?]]  // Mảng 2 chiều lưu trữ quân cờ, có thể là nil nếu ô trống
    
    init() {
        // Khởi tạo bàn cờ và đặt quân cờ vào vị trí ban đầu
        pieces = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        setupBoard()
    }

    mutating func setupBoard() {
        // Đặt quân cờ trắng ở hàng 6 và quân cờ đen ở hàng 1
        for i in 0..<8 {
            pieces[6][i] = Pawn(color: .white, position: (6, i)) // Quân cờ trắng
            pieces[1][i] = Pawn(color: .black, position: (1, i)) // Quân cờ đen
        }

        // Đặt các quân khác (xe, mã, tượng, vua, hậu)
        pieces[7][0] = Rook(color: .white, position: (7, 0))
        pieces[7][1] = Knight(color: .white, position: (7, 1))
        pieces[7][2] = Bishop(color: .white, position: (7, 2))
        pieces[7][3] = Queen(color: .white, position: (7, 3))
        pieces[7][4] = King(color: .white, position: (7, 4))
        pieces[7][5] = Bishop(color: .white, position: (7, 5))
        pieces[7][6] = Knight(color: .white, position: (7, 6))
        pieces[7][7] = Rook(color: .white, position: (7, 7))

        pieces[0][0] = Rook(color: .black, position: (0, 0))
        pieces[0][1] = Knight(color: .black, position: (0, 1))
        pieces[0][2] = Bishop(color: .black, position: (0, 2))
        pieces[0][3] = Queen(color: .black, position: (0, 3))
        pieces[0][4] = King(color: .black, position: (0, 4))
        pieces[0][5] = Bishop(color: .black, position: (0, 5))
        pieces[0][6] = Knight(color: .black, position: (0, 6))
        pieces[0][7] = Rook(color: .black, position: (0, 7))
    }

}
