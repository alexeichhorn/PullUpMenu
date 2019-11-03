//
//  AnimatablePullUpButton.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 27.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

public class AnimatablePullUpButton: UIControl {
    
    private var arrowLayer = CAShapeLayer()
    
    //fileprivate let lineWidth: CGFloat = 5
    fileprivate let arrowHeightFactor: CGFloat = 0.4
    
    enum Direction {
        case up
        case down
        
        func reversed() -> Direction {
            return self == .up ? .down : .up
        }
    }
    
    private(set) var currentDirection: Direction = .up
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init(frame: CGRect, direction: Direction) {
        currentDirection = direction
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .clear
        
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        
    }
    
    override public func draw(_ rect: CGRect) {
        drawArrow(currentDirection, inRect: rect)
    }
    
    private func drawArrow(_ direction: Direction, inRect rect: CGRect) {
        
        let lineWidth = strokeWidth(for: rect.size)
        
        let path = arrowPath(direction, inRect: rect)
        
        arrowLayer.frame = rect
        arrowLayer.path = path.cgPath
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.lineWidth = lineWidth
        arrowLayer.lineJoin = .round
        arrowLayer.lineCap = .round
        arrowLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(arrowLayer)
    }
    
    private func arrowPath(_ direction: Direction, inRect rect: CGRect) -> UIBezierPath {
        
        let rect = arrowRect(for: rect)
        
        var yHead: CGFloat = (1-arrowHeightFactor)/2*rect.size.height
        var yBehind: CGFloat = (0.5+arrowHeightFactor/2)*rect.size.height
        
        if direction == .down {
            (yHead, yBehind) = (yBehind, yHead)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + yBehind))
        path.addLine(to: CGPoint(x: rect.minX + rect.size.width/2, y: rect.minY + yHead))
        path.addLine(to: CGPoint(x: rect.minX + rect.size.width, y: rect.minY + yBehind))
        path.lineCapStyle = .round
        
        return path
    }
    
    private func strokeWidth(for size: CGSize) -> CGFloat {
        return 5/40*size.width
    }
    
    private func arrowRect(for rect: CGRect) -> CGRect {
        let lineWidth = strokeWidth(for: rect.size)
        let insets = UIEdgeInsets(top: lineWidth, left: lineWidth, bottom: lineWidth, right: lineWidth)
        return rect.inset(by: insets)
    }
    
    
    // MARK: - Direction Animation
    
    func setDirection(_ direction: Direction, animated: Bool) {
        
        if currentDirection == direction { return }
        currentDirection = direction
        
        if animated {
            animate(toDirection: direction, duration: 0.5)
        } else {
            arrowLayer.path = arrowPath(direction, inRect: arrowLayer.frame).cgPath
        }
    }
    
    /// more precise way to animate to different direction by customizing duration of animation
    /// - Note: will start animation always from opposite direction, not from current direction
    func animate(toDirection direction: Direction, duration: TimeInterval, toFrame destinationFrame: CGRect? = nil) {
        
        arrowLayer.removeAllAnimations()
        
        currentDirection = direction
        
        let startRect = self.bounds
        let endRect = CGRect(origin: .zero, size: destinationFrame?.size ?? self.bounds.size)
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.fromValue = arrowPath(direction.reversed(), inRect: startRect).cgPath
        animation.toValue = arrowPath(direction, inRect: endRect).cgPath
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        
        arrowLayer.add(animation, forKey: "path")
        
        
        if let destinationSize = destinationFrame?.size {
            let strokeAnimation = CABasicAnimation(keyPath: "lineWidth")
            strokeAnimation.duration = duration
            strokeAnimation.fromValue = strokeWidth(for: self.frame.size)
            strokeAnimation.toValue = strokeWidth(for: destinationSize)
            strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            strokeAnimation.fillMode = .both
            strokeAnimation.isRemovedOnCompletion = false
            
            arrowLayer.add(strokeAnimation, forKey: "lineWidth")
        }
        
    }
    
    
    func animateTintColor(to finalColor: UIColor, duration: TimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "strokeColor")
        animation.duration = duration
        animation.fromValue = arrowLayer.strokeColor
        animation.toValue = finalColor.cgColor
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        
        arrowLayer.add(animation, forKey: "strokeColor")
    }
    
    var animatedLayer: CALayer {
        return arrowLayer
    }
    
    
    // MARK: Touch Handler
    
    private var selectionAnimator = UIViewPropertyAnimator()
    
    @objc private func touchDown() {
        selectionAnimator.stopAnimation(true)
        alpha = 0.5
    }
    
    @objc private func touchUp() {
        selectionAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.alpha = 1
        })
        selectionAnimator.startAnimation()
    }
    
    
}
