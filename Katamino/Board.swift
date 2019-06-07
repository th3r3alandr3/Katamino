//
//  Board.swift
//  Katamino
//
//  Created by Andre Eidemann on 16.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import Foundation
import CoreGraphics

public class Board: Grid {
    public var playgroundDescription: Any = "Board"
    
    
    private (set) public var rows: [[Bool]]
    
    private let emptyBoard: [[Bool]]
    
    //Sotrage for placed tiles
    private struct PlacedTile {
        let field: Field
        let tile: Tile
    }
    
    //Update rows wen placedTiles is changed
    private var placedTiles = [PlacedTile]() {
        didSet {
            updateRows()
        }
    }
    
    //Size of the board
    public struct Size {
        let height: Int
        let width: Int
        //Default
        public static let defaultSize = Size(height: 8, width: 8)
    }
    
    public init(size: Size) {
        //Create the empty board with padding for tiles
        
        let horizontalPadding = [Bool].init(repeating: true, count: 4)
        let verticalPadding = [[Bool]].init(repeating: [Bool].init(repeating: true, count: 8 + size.width), count: 4)
        let emptyRow = [Bool].init(repeating: false, count: size.width)
        rows = verticalPadding
        for _ in 0..<size.height {
            rows += [horizontalPadding + emptyRow + horizontalPadding]
        }
        rows += verticalPadding
        emptyBoard = rows
    }
}

extension Board {
    //Check if the filed can be dopped at the point,.
    //Returns field or nil
    public func allowedDropLocation(for tile: Tile, at point: CGPoint, fieldSize: CGFloat) -> Field? {
        let potentialField = fieldAt(point, fieldSize: fieldSize)
        var allowedDropLocation: Field?
        if allowedPosition(tile, at: potentialField) {
            allowedDropLocation = potentialField
        } else {
            var distanceToDropPoint = CGFloat.greatestFiniteMagnitude
            for field in fieldsSurrounding(potentialField) {
                if allowedPosition(tile, at: field) {
                    let origin = pointAtOriginOf(field, fieldSize: fieldSize)
                    let xDistance = origin.x - point.x
                    let yDistance = origin.y - point.y
                    let distance = (xDistance * xDistance) + (yDistance * yDistance)
                    if distance < distanceToDropPoint {
                        distanceToDropPoint = distance
                        allowedDropLocation = field
                    }
                }
            }
        }
        return allowedDropLocation
    }
    
    //Check if the tile can be placed on this field
    public func allowedPosition(_ tile: Tile, at field: Field) -> Bool {
        //Ceck for every field of the tile if it can be placed
        for tileField in tile.fields() {
            let boardField = tileField.offsetBy(field)
            //Check if the field ot the tile is within the board
            if !fieldWithinGrid(boardField) {
                return false
            }
            //Check if the target field is occupied
            if tileField.occupied == true && fieldOccupied(boardField) {
                return false
            }
        }
        return true
    }
    
    //Place the tile
    public func setPostionOf(_ tile: Tile, at field: Field) -> Bool {
        if !allowedPosition(tile, at: field) {
            return false
        }
        placedTiles.append(PlacedTile(field: field, tile: tile))
        return true
    }
    
    //Get placed tile by field
    public func tileAt(_ field: Field) -> Tile? {
        for placedTile in placedTiles {
            let locationInTile = field.offsetBy(-placedTile.field)
            if placedTile.tile.fieldWithinGrid(locationInTile) {
                for tileField in placedTile.tile.occupiedFields() {
                    if tileField == locationInTile {
                        return placedTile.tile
                    }
                }
            }
        }
        return nil
    }
    
    //Function to remove the tile
    public func remove(_ tile: Tile) -> Tile? {
        if let index = placedTiles.index( where: { $0.tile === tile } ){
            placedTiles.remove(at: index)
            return tile
        }
        return nil
    }
    
    //Update rows by placed tiles
    private func updateRows() {
        rows = emptyBoard
        for placedTile in placedTiles {
            for tileField in placedTile.tile.occupiedFields() {
                let boardLocation = tileField.offsetBy(placedTile.field)
                rows[boardLocation.row][boardLocation.column] = true
            }
        }
    }
}
