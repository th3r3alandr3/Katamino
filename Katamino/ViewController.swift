//
//  ViewController.swift
//  Katamino
//
//  Created by Andre Eidemann on 14.05.19.
//  Copyright © 2019 Andre Eidemann. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet var doubleTab: UITapGestureRecognizer!
    @IBOutlet var pan: UIPanGestureRecognizer!
    @IBOutlet weak var player: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    
    private let fieldSize: CGFloat = 40
    var boardView: BoardView!
    var tileViews: [TileView]!
    var popup: UIView!
    var currentPlayer = 1
    var timers = Timer()
    let timePerRound = 20
    var seconds = 20
    
    public var board: Board! {
        didSet {
            boardView = BoardView(board: board, fieldSize: fieldSize)
        }
    }
    public var tiles = [Tile]() {
        didSet {
            tileViews = tiles.map { TileView(tile: $0) }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tap.require(toFail: doubleTab)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        timerLabel.text = "\(seconds)"
        createPopup()
        let rect = CGRect(x: 20, y: (popup.bounds.height - 50) / 2, width: popup.bounds.width-40, height: 50)
        createPopupButton(title: "Start Game", action: #selector(start), rect: rect)
    }
    
    private func createPopup(){
        popup = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        popup.backgroundColor = UIColor(white: 0, alpha: 0.75)
        self.view.addSubview(popup)
    }
    
    private func createPopupButton(title: String, action: Selector, rect: CGRect){
        let button = UIButton(frame: rect)
        button.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(255)) / 255, saturation: 1, brightness: 1, alpha: 1)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        popup.addSubview(button)
    }
    
    private func createPopupLabel(title: String, rect: CGRect, textColor: UIColor){
        let label = UILabel(frame: rect)
        label.textAlignment = .center
        label.text = title
        label.textColor = textColor
        popup.addSubview(label)
    }
    
    private func clearPopupView() {
        for view in popup.subviews{
            view.removeFromSuperview()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func startTimer(){
        timers = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    private func restartTimer(){
        stopTimer()
        seconds = timePerRound
        timerLabel.text = "\(seconds)"
        timerLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        startTimer()
    }
    
    private func stopTimer(){
        timers.invalidate()
    }
    
    @objc private func updateTimer(){
        seconds -= 1
        
        switch seconds {
        case 5:
            timerLabel.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            timerLabel.text = "\(seconds)"
        case 0:
            playerLost()
            timerLabel.text = "\(seconds)"
            stopTimer()
        default:
            timerLabel.text = "\(seconds)"
        }
    }
    
    private func playerLost(){
        clearPopupView()
        let buttonRect = CGRect(x: 20, y: (popup.bounds.height - 50) / 2, width: popup.bounds.width-40, height: 50)
        createPopupButton(title: "Restart", action: #selector(restart), rect: buttonRect)
        let labelRect = CGRect(x: 20, y: (popup.bounds.height - 50) / 2 - 100, width: popup.bounds.width-40, height: 50)
        createPopupLabel(title: String(format:"Player %i Lost", currentPlayer), rect: labelRect, textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        self.view.addSubview(popup)
        self.view.bringSubviewToFront(popup)
    }
    
    private func switchPlayer(){
        currentPlayer = currentPlayer == 1 ? 2 : 1
        player.text = String(format:"Player %i", currentPlayer)
    }
    
    @IBAction func start(_ sender: Any) {
        let board = Board(size: .defaultSize)
        let tiles = (0..<12).map { Tile(index: $0!) }
        self.board = board
        self.tiles = tiles
        view.addSubview(boardView)
        tileViews.forEach { view.addSubview($0) }
        boardView.center = view.center
        placeTiles()
        startTimer()
        popup.removeFromSuperview()
    }
    
    @IBAction func restart(_ sender: Any) {
        self.resetGame()
        popup.removeFromSuperview()
    }
    
    private func tilesLeft() -> Bool {
        for tile in self.tiles {
            if !tile.isLocked {
                return true
            }
        }
        return false
    }
    
    @IBAction func reset(_ sender: Any) {
        let alert = UIAlertController(title: "Reset", message: "Start again?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.resetGame()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        guard let activeTile = activeTile else { return }
        activeTile.rotate()
        boardView.showDropPathAt(nil)
        self.activeTile = nil
    }
    
    @IBAction func handleDobuleTap(_ sender: UITapGestureRecognizer) {
        guard let activeTile = activeTile else { return }
        activeTile.reflect()
        boardView.showDropPathAt(nil)
        self.activeTile = nil
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let activeTile = activeTile else { return }
        
        var fingerClearedLocation = sender.location(in: view)
        fingerClearedLocation.y -= activeTile.bounds.height * 0.5
        switch sender.state {
        case .began:
            UIView.animate(withDuration: 0.1, animations: { activeTile.center = fingerClearedLocation })
        case .changed:
            activeTile.center = fingerClearedLocation
            let locationOnBoard = boardView.convert(activeTile.bounds.origin, from: activeTile)
            if let allowedDropLocation = board.allowedDropLocation(for: activeTile.tile, at:locationOnBoard, fieldSize: fieldSize) {
                let fieldOrigin = board.pointAtOriginOf(allowedDropLocation, fieldSize: fieldSize)
                boardView.showDropPathAt(fieldOrigin)
            } else {
                boardView.showDropPathAt(nil)
            }
        case .ended, .cancelled:
            let locationOnBoard = boardView.convert(activeTile.bounds.origin, from: activeTile)
            let allowedDropLocation = board.allowedDropLocation(for: activeTile.tile, at:locationOnBoard, fieldSize: fieldSize)
            boardView.showDropPathAt(nil)
            self.activeTile = nil
            
            if let allowedDropLocation = allowedDropLocation {
                let _ = board.position(activeTile.tile, at: allowedDropLocation)
                activeTile.tile.isLocked = true
                boardView.addSubviewPreservingLocation(activeTile)
                UIView.animate(withDuration: 0.1, animations: {
                    activeTile.frame.origin = self.board.pointAtOriginOf(allowedDropLocation, fieldSize: self.fieldSize)
                }, completion: { _ in
                    self.switchPlayer()
                    if(self.tilesLeft()){
                        self.restartTimer()
                    }
                    else{
                        self.stopTimer()
                        self.playerLost()
                    }
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    activeTile.resetSize()
                    self.placeTiles()
                })
            }
        default:
            break
        }
    }
    
    private func placeTiles() {
        for (index, tileView) in tileViews.enumerated() {
            if tileView.superview != view || tileView == activeTile {
                continue
            }
            switch index {
            case 0...2 :
                tileView.center.x = (view.bounds.width / 4)  * CGFloat(index + 1)
                tileView.center.y = tileView.bounds.height
            case 3...5 :
                tileView.center.x = (view.bounds.width / 4)  * CGFloat(index - 2)
                tileView.center.y = (tileView.bounds.height * 2) + 10
            case 6...8:
                tileView.center.x = (view.bounds.width / 4)  * CGFloat(index - 5)
                tileView.center.y = view.bounds.height - tileView.bounds.height * 2 - 10
            default:
                tileView.center.x = (view.bounds.width / 4)  * CGFloat(index - 8)
                tileView.center.y = view.bounds.height - tileView.bounds.height
            }
        }
    }
    
    var activeTile: TileView? {
        willSet {
            if let oldActiveTile = activeTile {
                if !oldActiveTile.tile.willRotate {
                    oldActiveTile.isLifted = false
                    oldActiveTile.layer.zPosition = 5
                }
            }
        }
        didSet {
            if activeTile != nil && activeTile!.tile.isLocked {
                self.activeTile = nil
                return
            }
            if activeTile != nil && activeTile!.tile.willRotate {
                return
            }
            if let newActiveTile = activeTile {
                newActiveTile.isLifted = true
                newActiveTile.layer.zPosition = 10
                boardView.dropPath = newActiveTile.tile.pathForFields(true, fieldSize: fieldSize)
                if newActiveTile.superview != view {
                    view.addSubviewPreservingLocation(newActiveTile)
                    let _ = board.remove(newActiveTile.tile)
                }
            }
        }
    }
    
    private func resetGame() {
        for tileView in tileViews {
            if tileView.superview != view {
                view.addSubviewPreservingLocation(tileView)
                let _ = board.remove(tileView.tile)
                tileView.tile.isLocked = false
                tileView.resetSize()
            }
        }

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: -10, options: [], animations: {
            self.placeTiles()
        }, completion: { _ in
            self.restartTimer()
        })
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: view)
        if let hitTile = view.hitTest(location, with: nil) as? TileView {
            hitTile.tile.willRotate = gestureRecognizer != pan
            activeTile = hitTile
            return true
        }
        return false
    }
}

