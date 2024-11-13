//
//  Pawn.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class Pawn: ChessPiece {
    var isPromoted: Bool = false
    let direction: Int
    let startRow: Int
    
    override init(color: PlayerColor, position: (Int, Int)) {
        self.direction = position.0 == 6 ? -1 : 1
        self.startRow = position.0
        super.init(color: color, position: position)
    }

    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()
        let nextPosition = (position.0 + self.direction, position.1)

        // Kiểm tra xem vị trí tiếp theo có quân cờ nào không (1 ô về phía trước)
        if nextPosition.0 >= 0 && nextPosition.0 < 8 && board[nextPosition.0][nextPosition.1] == nil {
            moves.append(nextPosition)

            // Kiểm tra nếu quân Pawn đang ở vị trí khởi đầu để có thể đi 2 ô
            let doubleStepPosition = (position.0 + 2 * self.direction, position.1)
            if position.0 == startRow && board[doubleStepPosition.0][doubleStepPosition.1] == nil {
                moves.append(doubleStepPosition) // Đi thêm 2 ô về phía trước
            }
        }

        // Thêm các luật di chuyển khác của Pawn (ví dụ: ăn chéo)
        let diagonalLeft = (position.0 + self.direction, position.1 - 1)
        let diagonalRight = (position.0 + self.direction, position.1 + 1)

        if diagonalLeft.0 >= 0 && diagonalLeft.0 < 8 && diagonalLeft.1 >= 0 && diagonalLeft.1 < 8 {
            if let enemyPiece = board[diagonalLeft.0][diagonalLeft.1], enemyPiece.color != color {
                moves.append(diagonalLeft)
            }
        }

        if diagonalRight.0 >= 0 && diagonalRight.0 < 8 && diagonalRight.1 >= 0 && diagonalRight.1 < 8 {
            if let enemyPiece = board[diagonalRight.0][diagonalRight.1], enemyPiece.color != color {
                moves.append(diagonalRight)
            }
        }

        return moves
    }
    
    func promote(to newPiece: ChessPiece) {
        isPromoted = true
        // Cập nhật vị trí cho quân cờ mới
        self.position = newPiece.position
    }
}
