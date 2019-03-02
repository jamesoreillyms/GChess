//
//  Chess.swift
//  GChess
//
//  Created by James O'Reilly on 19/02/2019.
//  Copyright © 2019 James O'Reilly. All rights reserved.
//

import Foundation
import UIKit

protocol Piece {
    var color: PieceColor { get set }
    var directions: [Direction]? { get }
    var compositeDirections: [[Direction]]? { get }
    var magnitude: Int { get }
}

indirect enum Direction : CustomStringConvertible {
    case outward
    case inward
    case left
    case right

    func move() -> Moveable {
        switch self {
        case .left: return Left()
        case .right: return Right()
        case .outward: return Outward()
        case .inward: return Inward()
        }
    }

    var description: String {
        switch self {
        case .left: return "⬅"
        case .right: return "➡"
        case .outward: return "⬆"
        case .inward: return "⬇"
        }
    }
}

protocol Moveable {
    var transform: Int { get }
    var operation: (Int, Int) -> Int { get }
}

struct Outward: Moveable {
    let transform: Int = 8
    let operation: (Int, Int) -> Int = (-)
}

struct Inward: Moveable {
    let transform: Int = 8
    let operation: (Int, Int) -> Int = (+)
}

struct Left: Moveable {
    let transform: Int = 1
    let operation: (Int, Int) -> Int = (-)
}

struct Right: Moveable {
    let transform: Int = 1
    let operation: (Int, Int) -> Int = (+)
}

struct Position {
    var square: (row: Int, column: Int)
}

enum PieceColor {
    case black
    case white
}

struct Rook: Piece, CustomStringConvertible {
    var color: PieceColor
    var directions: [Direction]? = [.left, .right, .outward, .inward]
    var compositeDirections: [[Direction]]?
    let magnitude = 8
    var description: String {
        switch color {
        case .black: return "♜"
        default: return "♖"
        }
    }

    init(color: PieceColor) {
        self.color = color
        self.compositeDirections = nil
    }
}

struct Bishop: Piece, CustomStringConvertible {
    var color: PieceColor
    var directions: [Direction]?
    var compositeDirections: [[Direction]]? = [[.outward, .left], [.outward, .right], [.inward, .left], [.inward, .right]]
    let magnitude = 8
    var description: String {
        switch color {
        case .black: return "♝"
        default: return "♗"
        }
    }

    init(color: PieceColor) {
        self.color = color
        self.directions = nil
    }
}

struct King: Piece, CustomStringConvertible {
    var color: PieceColor
    var directions: [Direction]? = [.outward, .inward, .left, .right]
    var compositeDirections: [[Direction]]? = [[.outward, .left], [.outward, .right], [.inward, .left], [.inward, .right]]
    var magnitude = 1
    var description: String {
        switch color {
        case .black: return "♚"
        default: return "♔"
        }
    }

    init(color: PieceColor) {
        self.color = color
    }
}

struct Queen: Piece, CustomStringConvertible {
    var color: PieceColor
    var directions: [Direction]? = [.outward, .inward, .left, .right]
    var compositeDirections: [[Direction]]? = [[.outward, .left], [.outward, .right], [.inward, .left], [.inward, .right]]
    var magnitude = 8
    var description: String {
        switch color {
        case .black: return "♛"
        default: return "♕"
        }
    }

    init(color: PieceColor) {
        self.color = color
    }
}

struct Knight: Piece, CustomStringConvertible {
    var color: PieceColor
    var compositeDirections: [[Direction]]? = [[.left, .left, .inward],
                                               [.left, .left, .outward],
                                               [.outward, .outward, .left],
                                               [.outward, .outward, .right],
                                               [.right, .right, .outward],
                                               [.right, .right, .inward],
                                               [.inward, .inward, .left],
                                               [.inward, .inward, .right]]
    var directions: [Direction]?
    let magnitude: Int = 1
    var description: String {
        switch color {
        case .black: return "♞"
        default: return "♘"
        }
    }

    init(color: PieceColor) {
        self.color = color
        self.directions = nil
    }
}

// change to struct and observe
class Pawn: Piece, CustomStringConvertible {
    var color: PieceColor
    var directions: [Direction]? {
        switch color {
        case .black: return [.inward]
        default: return [.outward]
        }
    }
    var compositeDirections: [[Direction]]?

    var didMove = false
    var magnitude: Int {
        if didMove {
            return 1
        } else {
            return 2
        }
    }

    var description: String {
        switch color {
        case .black: return "♟"
        default: return "♙"
        }
    }

    init(color: PieceColor) {
        self.color = color
        self.compositeDirections = nil
    }
}
