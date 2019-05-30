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
    
    private struct PlacedTile {
        let field: Field
        let tile: Tile
    }
    
    private var placedTiles = [PlacedTile]() {
        didSet {
            updateRows()
        }
    }
    
    public struct Size {
        let height: Int
        let width: Int
        
        public static let defaultSize = Size(height: 8, width: 8)
        public static let SixByTen = Size(height: 6, width: 10)
        public static let FiveByTwelve = Size(height: 5, width: 12)
        public static let FourByFifteen = Size(height: 4, width: 15)
        public static let ThreeByTwenty = Size(height: 3, width: 20)
    }
    
    public init(size: Size) {
        let paddingLeftRight = [Bool].init(repeating: true, count: 4)
        let paddingTopBottom = [[Bool]].init(repeating: [Bool].init(repeating: true, count: 8 + size.width), count: 4)
        let emptyRow = [Bool].init(repeating: false, count: size.width)
        rows = paddingTopBottom
        for _ in 0..<size.height {
            rows += [paddingLeftRight + emptyRow + paddingLeftRight]
        }
        rows += paddingTopBottom
        emptyBoard = rows
    }
}

extension Board {
    
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
    
    public func allowedPosition(_ tile: Tile, at field: Field) -> Bool {
        
        for tileField in tile.fields() {
            let boardField = tileField.offsetBy(field)
            if !fieldWithinGrid(boardField) {
                return false
            }
            if tileField.occupied == true && fieldOccupied(boardField) {
                return false
            }
        }
        return true
    }
    
    public func position(_ tile: Tile, at field: Field) -> Bool {
        if !allowedPosition(tile, at: field) {
            return false
        }
        placedTiles.append(PlacedTile(field: field, tile: tile))
        return true
    }
    
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
    
    public func remove(_ tile: Tile) -> Tile? {
        if let index = placedTiles.index( where: { $0.tile === tile } ){
            placedTiles.remove(at: index)
            return tile
        }
        return nil
    }
    
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
