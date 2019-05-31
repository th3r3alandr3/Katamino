//
//  BoardView.swift
//  Katamino
//
//  Created by Andre Eidemann on 17.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import UIKit

class BoardView: UIView {

    private let board: Board
    public let fieldSize: CGFloat
    
    private let highlightLayer: CAShapeLayer = {
        $0.anchorPoint = CGPoint(x: 0, y: 0)
        $0.fillColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.25).cgColor
        $0.strokeColor = UIColor.darkGray.cgColor
        $0.lineWidth = 4.0
        $0.zPosition = 2
        $0.isHidden = true
        return $0
    }(CAShapeLayer())
    
    public init(board: Board, fieldSize: CGFloat = 20) {
        self.board = board
        self.fieldSize = fieldSize
        super.init(frame: board.sizeForGrid(fieldSize))
        drawFields()
        layer.addSublayer(highlightLayer)
    }
    
    private func drawFields() {
        let gridLayer = CAShapeLayer()
        gridLayer.frame = bounds
        let fields = getFields(occupied: false)
        for field in fields {
            let originX = CGFloat(field.column) * fieldSize
            let originY = CGFloat(field.row) * fieldSize
            let rect =  CGRect(x: originX, y: originY, width: fieldSize, height: fieldSize)
            let path = UIBezierPath(rect: rect)
            let gridLayer = CAShapeLayer()
            let color = UIColor(patternImage: UIImage(named: "field")!)
            gridLayer.fillColor = color.cgColor
            gridLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            gridLayer.zPosition = 1
            layer.addSublayer(gridLayer)
            gridLayer.path = path.cgPath
        }
    }
    
    private func boardPath() -> CGPath {
        return board.pathForFields(false, fieldSize: fieldSize)
    }
    
    func getFields(occupied: Bool) -> [Field] {
        return board.fields().filter { $0.occupied == occupied }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension BoardView {
    
    var dropPath: CGPath? {
        set {
            let origin = highlightLayer.position
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            highlightLayer.path = newValue
            highlightLayer.position = origin
            CATransaction.commit()
        }
        get {
            return highlightLayer.path
        }
    }
    
    func showDropPathAt(_ origin: CGPoint?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let origin = origin {
            highlightLayer.position = origin
            highlightLayer.isHidden = false
        } else {
            highlightLayer.isHidden = true
        }
        CATransaction.commit()
    }
}

extension BoardView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let field = board.fieldAt(point, fieldSize: fieldSize)
        if
            let tile = board.tileAt(field),
            let tileView = (tileViews.filter{ $0.tile.index == tile.index}).first {
            return tileView
        }
        
        return super.hitTest(point, with: event)
    }
    
    var tileViews: [TileView] {
        return subviews.filter { $0 is TileView } as! [TileView]
    }
}

