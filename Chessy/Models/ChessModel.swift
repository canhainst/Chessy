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
