//
//  Queen.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

import Foundation

class Queen: ChessPiece {
    override init(color: PlayerColor, position: (Int, Int)) {
        super.init(color: color, position: position)
    }

    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()
        let row = position.0
        let col = position.1
        
        // Các hướng di chuyển của quân Hậu (8 hướng)
        let directions = [
            (1, 0), (-1, 0), (0, 1), (0, -1),  // lên, xuống, phải, trái
            (1, 1), (1, -1), (-1, 1), (-1, -1) // chéo phải trên, chéo trái trên, chéo phải dưới, chéo trái dưới
        ]
        
        for direction in directions {
            var newRow = row
            var newCol = col
            
            // Tiếp tục di chuyển theo hướng này cho đến khi gặp quân cờ hoặc ra ngoài bàn cờ
            while true {
                newRow += direction.0
                newCol += direction.1
                
                // Kiểm tra biên
                if newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8 {
                    break
                }
                
                if let piece = board[newRow][newCol] {
                    // Nếu gặp quân cờ cùng màu thì không thể đi tiếp
                    if piece.color == self.color {
                        break
                    }
                    // Nếu gặp quân đối thủ thì có thể ăn
                    moves.append((newRow, newCol))
                    break // Dừng lại sau khi đã ăn quân đối thủ
                } else {
                    // Ô trống, có thể di chuyển
                    moves.append((newRow, newCol))
                }
            }
        }
        
        return moves
    }
}
