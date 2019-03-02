//
//  GameViewController.swift
//  GChess
//
//  Created by James O'Reilly on 19/02/2019.
//  Copyright © 2019 James O'Reilly. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var board: UICollectionView!

    var boardState: Board!
    var highlights = [Int](repeating: -1, count: 64)

    override func viewDidLoad() {
        super.viewDidLoad()
        boardState = Board()
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if boardState.highlightingSource != nil {
            if highlights.contains(indexPath.item) {
                // move the piece
                let piece = boardState.piece(atIndex: boardState.highlightingSource!)
                boardState.pieces[indexPath.item] = piece
                boardState.pieces[boardState.highlightingSource!] = nil

                // if piece is a pawn, update it's didMove to reduce it's magnitude
                if type(of: piece!) == Pawn.self {
                    let pawn = piece as! Pawn
                    pawn.didMove = true
                }
            }
            highlights = [Int](repeating: -1, count: 64) // reset highlight array
            boardState.highlightingSource = nil
        } else {
            if let piece = boardState.piece(atIndex: indexPath.item) {
                highlights = boardState.squaresToHighlight(forSelectedPiece: piece, fromIndex: indexPath.item)
                boardState.highlightingSource = indexPath.item
            }
        }
        board.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath) as? SquareCell

        if let piece = boardState!.pieces[indexPath.item] {
            cell!.content.text = "\(piece)"
        } else {
            cell!.content.text = ""
        }
        cell!.highlight.backgroundColor = .clear
        cell!.backgroundColor = Board.colorForSquare(atIndex: indexPath.item)
        if highlights.contains(indexPath.item) {
            let color = UIColor.init(red: 0, green: 0, blue: 100, alpha: 0.2)
            cell!.highlight.backgroundColor = color
        }

        return cell!
    }
}

extension GameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/8, height: view.frame.width/8)
    }
}
