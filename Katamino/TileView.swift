//
//  TileView.swift
//  Katamino
//
//  Created by Andre Eidemann on 16.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import UIKit

class TileView: UIView {

    public override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    
    private var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    let tile: Tile
    private var size: CGFloat
    
    public init(tile: Tile, size: CGFloat = 20.0) {
        self.tile = tile
        self.size = size
        super.init(frame:tile.sizeForGrid(size))
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.fillColor = UIColor(hue: CGFloat(arc4random_uniform(255)) / 255, saturation: 1, brightness: 1, alpha: 1).cgColor
        shapeLayer.path = tilePath()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func tilePath() -> CGPath {
        return tile.pathForFields(true, fieldSize: size)
    }
    
    func rotate() {
        self.tile.rotate()
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi * 0.5)
        }, completion: { _ in
            self.transform = CGAffineTransform.identity
            self.shapeLayer.path = self.tilePath()
        })
    }
    
    func reflect() {
        self.tile.reflect()
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        }, completion: { _ in
            self.transform = CGAffineTransform.identity
            self.shapeLayer.path = self.tilePath()
        })
    }
    
    func resetSize() {
        self.size = 20
        self.shapeLayer.path = self.tilePath()
    }
    
    public var isLifted: Bool = false {
        didSet {
            self.size = 40
            UIView.animate(withDuration: 0.5) {
                self.shapeLayer.path = self.tilePath()
            }
            layer.shadowRadius = 5.0
            layer.shadowOffset = .zero
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = isLifted ? 0.5 : 0.0
        }
    }
    
    public var isLocked: Bool {
        get{
            return self.tile.isLocked
        }
        set(locked){
            self.tile.isLocked = locked
        }
    }

}
