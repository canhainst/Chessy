//
//  Pawn.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class Pawn: ChessPiece {
    override init(color: PlayerColor, position: (Int, Int)) {
        super.init(color: color, position: position)
    }

    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()
        let direction = color == .white ? -1 : 1
        let nextPosition = (position.0 + direction, position.1)

        // Kiểm tra xem vị trí tiếp theo có quân cờ nào không (1 ô về phía trước)
        if nextPosition.0 >= 0 && nextPosition.0 < 8 && board[nextPosition.0][nextPosition.1] == nil {
            moves.append(nextPosition)

            // Kiểm tra nếu quân Pawn đang ở vị trí khởi đầu để có thể đi 2 ô
            let startRow = color == .white ? 6 : 1
            let doubleStepPosition = (position.0 + 2 * direction, position.1)
            if position.0 == startRow && board[doubleStepPosition.0][doubleStepPosition.1] == nil {
                moves.append(doubleStepPosition) // Đi thêm 2 ô về phía trước
            }
        }

        // Thêm các luật di chuyển khác của Pawn (ví dụ: ăn chéo)
        let diagonalLeft = (position.0 + direction, position.1 - 1)
        let diagonalRight = (position.0 + direction, position.1 + 1)

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

}

