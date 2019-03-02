//
//  Board.swift
//  GChess
//
//  Created by James O'Reilly on 28/02/2019.
//  Copyright © 2019 James O'Reilly. All rights reserved.
//

import Foundation
import UIKit

struct Board {
    var pieces = [Piece?]()
    var highlightingSource: Int?

    init() {
        for square in 0...63 {
            if square == 4 {
                pieces.append(King(color: .black))
            } else if square == 1 || square == 6 {
                pieces.append(Knight(color: .black))
            } else if 8...15 ~= square {
                pieces.append(Pawn(color: .black))
            } else if square == 2 || square == 5 {
                pieces.append(Bishop(color: .black))
            } else if square == 3 {
                pieces.append(Queen(color: .black))
            } else if square == 0 || square == 7 {
                pieces.append(Rook(color: .black))
            } else if square == 56 || square == 63 {
                pieces.append(Rook(color: .white))
            } else if square == 57 || square == 62 {
                pieces.append(Knight(color: .white))
            } else if 48...55 ~= square {
                pieces.append(Pawn(color: .white))
            } else if square == 60 {
                pieces.append(King(color: .white))
            } else if square == 58 || square == 61 {
                pieces.append(Bishop(color: .white))
            } else if square == 59 {
                pieces.append(Queen(color: .white))
            } else {
                pieces.append(nil)
            }
        }
    }

    let leftEdges = [0, 8, 16, 24, 32, 40, 48, 56]
    let rightEdges = [7, 15, 23, 31, 39, 47, 55, 63]

    private func concernedEdges(direction: Direction) -> [Int] {
        var edges = [Int]()
        switch direction {
        case .left:
            edges += leftEdges
        case .right:
            edges += rightEdges
        default:
            edges = []
        }
        return edges
    }

    private func applyTransformToIndex(_ currentIndex: Int, transform: Int, operation: (Int, Int) -> Int) -> Int? {
        var newIndex: Int?
        let desiredIndex = operation(currentIndex, transform)
        if desiredIndex >= 0 && desiredIndex < 64 {
            newIndex = desiredIndex
        }
        return newIndex
    }

    private func isDesiredIndexValidForDirection(_ direction: Direction, currentIndex: Int, desiredIndex: Int, finalMove: Bool) -> Bool {
        let edges = concernedEdges(direction: direction)
        if !edges.contains(currentIndex) {
            if !finalMove {
                return true
            } else if !squareOccupied(atIndex: desiredIndex) {
                return true
            }
        }
        return false
    }

    private func getNextIndexForDirection(_ direction: Direction, fromIndex currentIndex: Int) -> Int? {
        var transform: Int?
        switch direction {
        case .left, .right, .outward, .inward:
            if let nextIndex = applyTransformToIndex(currentIndex, transform: direction.move().transform, operation: direction.move().operation) {
                transform = nextIndex
            }
        }
        return transform
    }

    public func squaresToHighlight(forSelectedPiece piece: Piece, fromIndex index: Int) -> [Int] {
        var squares = [Int]()
        var currentIndex = index
        print("============================== \(piece) selected  on square \(index) ==============================")
        print("This piece can move to a maximum of \(piece.magnitude) squares in each of it's directions")

        if let compositeDirections = piece.compositeDirections {
            print("Composite directions detected")
            print("Found \(compositeDirections.count) composite directions")
            for directions in compositeDirections {
                checkingInDirectionLoop: for _ in 1...piece.magnitude {
                    print("Currently checking in \(directions) direction from square \(currentIndex)")
                    for (index, direction) in directions.enumerated() {
                        let lastDirectionInList = (directions[index] == directions.last) ? true : false
                        if let desiredIndex = getNextIndexForDirection(direction, fromIndex: currentIndex) {
                            if isDesiredIndexValidForDirection(direction, currentIndex: currentIndex, desiredIndex: desiredIndex, finalMove: lastDirectionInList) {
                                currentIndex = desiredIndex
                                if lastDirectionInList {
                                    print(" ----------------------------------------------")
                                    print("| Adding index \(desiredIndex) to list of desirable squares |")
                                    print(" ----------------------------------------------")
                                    squares.append(desiredIndex)
                                }
                            } else {
                                print("🚫 Desired index \(desiredIndex) is blocked by another piece")
                                currentIndex = index
                                break checkingInDirectionLoop
                            }
                        } else {
                            print("🚫 Desired index is out of bounds")
                            currentIndex = index
                            break checkingInDirectionLoop
                        }
                    }
                }
                currentIndex = index
            }
        }

        if let directions = piece.directions {
            print("Standard directions detected")
            print("Found \(directions.count) standard directions")
            for direction in directions {
                checkingInDirectionLoop: for _ in 1...piece.magnitude {
                    print("Currently checking in \(direction) direction from square \(currentIndex)")
                    if let desiredIndex = getNextIndexForDirection(direction, fromIndex: currentIndex) {
                        if isDesiredIndexValidForDirection(direction, currentIndex: currentIndex, desiredIndex: desiredIndex, finalMove: true) {
                            print(" ----------------------------------------------")
                            print("| Adding index \(desiredIndex) to list of desirable squares |")
                            print(" ----------------------------------------------")
                            currentIndex = desiredIndex
                            squares.append(desiredIndex)
                        } else {
                            print("🚫 Desired index \(desiredIndex) is blocked by another piece")
                            currentIndex = index
                            break checkingInDirectionLoop
                        }
                    } else {
                        print("🚫 Desired index is out of bounds")
                        currentIndex = index
                        break checkingInDirectionLoop
                    }
                }
                currentIndex = index
            }
        }
        return squares
    }

    public func piece(atIndex index: Int) -> Piece? {
        if let piece = pieces[index] {
            return piece
        }
        return nil
    }

    private func squareOccupied(atIndex index: Int) -> Bool {
        if pieces[index] != nil {
            return true
        }
        return false
    }

    // Returns a color based on the index of the chess square starting
    // at the top left from 0 and ending on the bottom right square at 63
    public static func colorForSquare(atIndex index: Int) -> UIColor {
        let rowIndex = index / 8
        let darkSquareColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        let lightSquareColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        if rowIndex.isEven() {
            return index.isEven() ? lightSquareColor : darkSquareColor
        }
        return index.isEven() ? darkSquareColor : lightSquareColor
    }
}

// MARK: Helper
extension Int {
    public func isEven() -> Bool {
        return self % 2 == 0
    }
}
