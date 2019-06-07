//
//  Grid.swift
//  Katamino
//
//  Created by Andre Eidemann on 15.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import Foundation
import UIKit

//The grid
public protocol Grid : CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    var rows: [[Bool]] { get }
    subscript(row: Int) -> [Bool] { get }
    func sizeForGrid(_ fieldSize: CGFloat) -> CGRect
    func pointAtOriginOf(_ field: Field, fieldSize: CGFloat) -> CGPoint
    func fieldAt(_ point: CGPoint, fieldSize: CGFloat) -> Field
}

//Mapping
extension Bool {
    var gridCharacter: String {
        return self ? "x" : " "
    }
}

//Create a field structure
public struct Field {
    public let row: Int
    public let column: Int
    public let occupied: Bool?
    
    public init(row: Int, column: Int, occupied: Bool? = nil) {
        self.row = row
        self.column = column
        self.occupied = occupied
    }
    //Get the offset
    func offsetBy(_ field: Field) -> Field {
        return Field(row: self.row + field.row, column: self.column + field.column)
    }
}

//Substrate fields
public prefix func -(field: Field) -> Field {
    return Field(row: -field.row, column: -field.column)
}

//Check Fields for equality
public func ==(left: Field, right: Field) -> Bool {
    return left.row == right.row && left.column == right.column
}

//Genrate fields iterativ from Bool array
public class GridFieldGenerator: IteratorProtocol {
    var row: Int = 0
    var column: Int = -1
    
    let grid: Grid
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    public func next() -> Field? {
        guard row < grid.rows.count else { return nil }
        
        column += 1
        
        if column == grid[row].count {
            column = 0
            row += 1
        }
        if row < grid.rows.count {
            return Field(row: row, column: column, occupied: grid[row][column])
        } else {
            return nil
        }
    }
}

//Sequenz to iterate grid
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
    //Get all fields from grid
    public func fields() -> GridFieldSequence {
        return GridFieldSequence(grid: self)
    }
    //Get all occupied fields from grid
    public func occupiedFields() -> [Field] {
        return fields().filter{ $0.occupied == true }
    }
    //Get surrounding fiedls by single field
    public func fieldsSurrounding(_ field: Field) -> [Field] {
        let row = field.row - 1
        let column = field.column - 1
        
        var fields = [Field]()
        for columnAdjust in 0..<3 {
            for rowAdjust in 0..<3 {
                fields.append(Field(row: row + rowAdjust, column: column + columnAdjust))
            }
        }
        
        return fields
    }
    
    //Get single row
    public subscript(row: Int) -> [Bool] {
        get {
            return rows[row]
        }
    }
    
    //Cehck if the field is within the grid
    public func fieldWithinGrid(_ field: Field) -> Bool {
        return field.row >= 0 && field.column >= 0 && field.row < rows.count && field.column < rows[field.row].count
    }
    
    //Check if the field is occupied
    public func fieldOccupied(_ field: Field) -> Bool {
        return self[field.row][field.column]
    }
    
    //Return path for fields with !occupied or occupied
    public func pathForFields(_ occupied: Bool, fieldSize: CGFloat) -> CGPath {
        
        let fieldsForPath = fields().filter { $0.occupied == occupied }
        
        //Draw rectangles from fields
        let rects : [CGRect] = fieldsForPath.map { field in
            let originX = CGFloat(field.column) * fieldSize
            let originY = CGFloat(field.row) * fieldSize
            return CGRect(x: originX, y: originY, width: fieldSize, height: fieldSize)
        }
        
        //Get and merge path from rectangles
        let path : UIBezierPath = rects.reduce(UIBezierPath()) { path, rect in
            path.append(UIBezierPath(rect: rect))
            return path
        }
        
        return path.cgPath
    }
    
    //Description is require
    public var description: String {
        let descriptions : [String] = rows.map { row in
            row.reduce("") { string, gridValue in
                string + gridValue.gridCharacter
            }
        }
        return descriptions.joined(separator: "\n")
    }
    
    //Set the grid size
    public func sizeForGrid(_ size: CGFloat) -> CGRect {
        let height = CGFloat(rows.count)
        let width = CGFloat(rows.first?.count ?? 0)
        return CGRect(origin: .zero, size: CGSize(width: size * width, height: size * height))
    }
    
    //Get origing point from field
    public func pointAtOriginOf(_ field: Field, fieldSize: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(field.column) * fieldSize, y: CGFloat(field.row) * fieldSize)
    }
    
    //Get field by point
    public func fieldAt(_ point: CGPoint, fieldSize: CGFloat) -> Field {
        let row = Int(floor(point.y / fieldSize))
        let column = Int(floor(point.x / fieldSize))
        return Field(row: row, column: column)
    }
}
