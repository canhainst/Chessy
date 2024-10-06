//
//  Bishop.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class Bishop: ChessPiece {
    override init(color: PlayerColor, position: (Int, Int)) {
        super.init(color: color, position: position)
    }
    
    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()
        let row = position.0
        let col = position.1
        
        // Các hướng di chuyển của quân Tượng
        let directions = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        for direction in directions {
            var newRow = row + direction.0
            var newCol = col + direction.1
            
            // Di chuyển theo đường chéo cho đến khi gặp biên bàn cờ hoặc gặp quân cờ khác
            while newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                if let piece = board[newRow][newCol] {
                    // Nếu gặp quân cờ cùng màu thì không thể đi tiếp
                    if piece.color == self.color {
                        break
                    }
                    // Nếu gặp quân đối thủ thì có thể ăn, nhưng không đi tiếp sau đó
                    moves.append((newRow, newCol))
                    break
                } else {
                    // Ô trống, có thể di chuyển
                    moves.append((newRow, newCol))
                }
                
                newRow += direction.0
                newCol += direction.1
            }
        }
        
        return moves
    }
}
