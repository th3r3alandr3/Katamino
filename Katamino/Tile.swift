//
//  Tile.swift
//  Katamino
//
//  Created by Andre Eidemann on 15.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import Foundation

public class Tile: Grid {
    public var playgroundDescription: Any = "Tile"
    private (set) public var rows: [[Bool]]
    let index: Int
    private var _isLocked : Bool = false
    private var _willRotate : Bool = false
    
    public init(index: Int) {
        //Get the shape of the tile by Index and Convart to Bool array
        rows = getShapeByIndex(index: index).map {
            return $0.map { $0 == "x" }
        }
        self.index = index
    }
    
    //Lock or unlock the tile
    var isLocked: Bool {
        get {
            return self._isLocked
        }
        set(lock) {
            self._isLocked = lock
        }
    }
    
    //Mark or unmark the tile for rotation
    var willRotate: Bool {
        get {
            return self._willRotate
        }
        set(rotate) {
            self._willRotate = rotate
        }
    }
    
    //Rotate the tile by 90°
    func rotate() {
        rows = rotateTile(rows)
        rows = rows.map { $0.reversed() }
    }
    
    //Reflect the tile
    func reflect(){
        rows = reflectTile(rows)
    }
    
}

//Function to reflect the tile inside the array
public func reflectTile<Bool>(_ input: [[Bool]]) -> [[Bool]] {
    if input.isEmpty { return [[Bool]]() }
    let count = input[0].count
    //Create an empty copy of the array
    var out = [[Bool]](repeating: [Bool](), count: count)
    for (index, outer) in input.enumerated() {
        //Append the array
        out[index] = outer
        //Refelct the array
        out[index].reverse()
    }
    return out
}

//Function to rotate the tile by 90° inside the array
public func rotateTile<Bool>(_ input: [[Bool]]) -> [[Bool]] {
    if input.isEmpty { return [[Bool]]() }
    let count = input[0].count
    //Create an empty copy of the array
    var out = [[Bool]](repeating: [Bool](), count: count)
    for outer in input {
        //Convert colums to rows
        for (index, inner) in outer.enumerated() {
            out[index].append(inner)
        }
    }
    
    return out
}

// Get shape of tiles as string array by index
private func getShapeByIndex(index: Int) -> [String] {
    switch index {
    case 0:
        return [
            "  x  ",
            "  x  ",
            "  x  ",
            "  x  ",
            "  x  "
        ]
    case 1:
        return [
            "     ",
            "  x  ",
            " xxx ",
            "  x  ",
            "     "
        ]
    case 2:
        return [
            "     ",
            " xx  ",
            "  x  ",
            "  x  ",
            "  x  "
        ]
    case 3:
        return [
            "     ",
            "  xx ",
            " xx  ",
            "  x  ",
            "     "
        ]
    case 4:
        return [
            "     ",
            "  xx ",
            "  xx ",
            "  x  ",
            "     "
        ]
    case 5:
        return [
            "     ",
            " xxx ",
            "  x  ",
            "  x  ",
            "     "
        ]
    case 6:
        return [
            "     ",
            "     ",
            " x x ",
            " xxx ",
            "     "
        ]
    case 7:
        return [
            "     ",
            " x   ",
            " x   ",
            " xxx ",
            "     "
        ]
    case 8:
        return [
            "     ",
            " x   ",
            " xx  ",
            "  xx ",
            "     "
        ]
        
    case 9:
        return [
            "     ",
            "  x  ",
            " xx  ",
            "  x  ",
            "  x  "
        ]
    case 10:
        return [
            "     ",
            " xx  ",
            "  x  ",
            "  xx ",
            "     "
        ]
    case 11:
        return [
            "  x  ",
            "  xx ",
            "   x ",
            "   x ",
            "     "
        ]
    default:
        return []
    }
}
