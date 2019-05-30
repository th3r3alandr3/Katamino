//
//  Grid.swift
//  Katamino
//
//  Created by Andre Eidemann on 15.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import Foundation
import UIKit

public protocol Grid : CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    var rows: [[Bool]] { get }
    subscript(row: Int) -> [Bool] { get }
    func sizeForGrid(_ fieldSize: CGFloat) -> CGRect
    func pointAtOriginOf(_ field: Field, fieldSize: CGFloat) -> CGPoint
    func fieldAt(_ point: CGPoint, fieldSize: CGFloat) -> Field
}

extension Bool {
    var gridCharacter: String {
        return self ? "x" : " "
    }
}

public struct Field {
    public let row: Int
    public let column: Int
    public let occupied: Bool?
    
    public init(row: Int, column: Int, occupied: Bool? = nil) {
        self.row = row
        self.column = column
        self.occupied = occupied
    }
    
    func offsetBy(_ field: Field) -> Field {
        return Field(row: self.row + field.row, column: self.column + field.column)
    }
}

public prefix func -(field: Field) -> Field {
    return Field(row: -field.row, column: -field.column)
}

public func ==(left: Field, right: Field) -> Bool {
    return left.row == right.row && left.column == right.column
}

public class GridFieldGenerator: IteratorProtocol {
    var currentRow: Int = 0
    var currentColumn: Int = -1
    
    let grid: Grid
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    public func next() -> Field? {
        guard currentRow < grid.rows.count else { return nil }
        
        currentColumn += 1
        
        if currentColumn == grid[currentRow].count {
            currentColumn = 0
            currentRow += 1
        }
        if currentRow < grid.rows.count {
            return Field(row: currentRow, column: currentColumn, occupied: grid[currentRow][currentColumn])
        } else {
            return nil
        }
    }
}

public class GridFieldSequence: Sequence {
    let grid: Grid
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    public func makeIterator() -> GridFieldGenerator {
        return GridFieldGenerator(grid: grid)
    }
}

extension Grid {
    public func fields() -> GridFieldSequence {
        return GridFieldSequence(grid: self)
    }
    public func occupiedFields() -> [Field] {
        return fields().filter{ $0.occupied == true }
    }
    public func fieldsSurrounding(_ field: Field) -> [Field] {
        let firstSurroundingRow = field.row - 1
        let firstSurroundingColumn = field.column - 1
        
        var fields = [Field]()
        for columnAdjust in 0..<3 {
            for rowAdjust in 0..<3 {
                fields.append(Field(row: firstSurroundingRow + rowAdjust, column: firstSurroundingColumn + columnAdjust))
            }
        }
        
        return fields
    }
    
    public subscript(row: Int) -> [Bool] {
        get {
            return rows[row]
        }
    }
    
    public func fieldWithinGrid(_ field: Field) -> Bool {
        return field.row >= 0 && field.column >= 0 && field.row < rows.count && field.column < rows[field.row].count
    }
    
    public func fieldOccupied(_ field: Field) -> Bool {
        return self[field.row][field.column]
    }
    
    public func pathForFields(_ occupied: Bool, fieldSize: CGFloat) -> CGPath {
        
        let fieldsForPath = fields().filter { $0.occupied == occupied }
        
        let rects : [CGRect] = fieldsForPath.map { field in
            let originX = CGFloat(field.column) * fieldSize
            let originY = CGFloat(field.row) * fieldSize
            return CGRect(x: originX, y: originY, width: fieldSize, height: fieldSize)
        }
        
        let path : UIBezierPath = rects.reduce(UIBezierPath()) { path, rect in
            path.append(UIBezierPath(rect: rect))
            return path
        }
        
        return path.cgPath
    }
    
    public var description: String {
        let descriptions : [String] = rows.map { row in
            row.reduce("") { string, gridValue in
                string + gridValue.gridCharacter
            }
        }
        return descriptions.joined(separator: "\n")
    }
    
    public func sizeForGrid(_ size: CGFloat) -> CGRect {
        let height = CGFloat(rows.count)
        let width = CGFloat(rows.first?.count ?? 0)
        return CGRect(origin: .zero, size: CGSize(width: size * width, height: size * height))
    }
    
    public func pointAtOriginOf(_ field: Field, fieldSize: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(field.column) * fieldSize, y: CGFloat(field.row) * fieldSize)
    }
    
    public func fieldAt(_ point: CGPoint, fieldSize: CGFloat) -> Field {
        let row = Int(floor(point.y / fieldSize))
        let column = Int(floor(point.x / fieldSize))
        return Field(row: row, column: column)
    }
}
