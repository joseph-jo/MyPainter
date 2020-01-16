//
//  PainterView.swift
//  PainterExample
//
//  Created by JosephChen on 2019/9/19.
//  Copyright © 2019 JosephChen. All rights reserved.
//

import UIKit

class PainterView: UIView {
    
    var eraseMode = false {
        didSet {
            if self.eraseMode == true {
                self.flattenLayers(drawingLayer: self.drawingLayer, max: 0)
            }
        }
    }
     
    var drawingLayer = MyDrawingShapeLayer()
    var touchList = [CGPoint]()
    let lineWidth: CGFloat = 20
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .scaleAspectFit
        self.layer.contents = UIImage(named: "BackgroundImg")?.cgImage
        self.layer.backgroundColor = UIColor.lightGray.cgColor
        
        self.drawingLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(self.drawingLayer)
    }
    
    override func layoutSubviews() {
        
        let frame = drawingLayer.frame
        if frame == .zero {
            drawingLayer.frame = self.frame
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let firstPt = touch.previousLocation(in: self)
        self.touchList.append(firstPt)
        
        removeAllSublayers(self.drawingLayer)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        self.touchList.append(touch.location(in: self))
        if self.eraseMode {
            let linePath = generateLine(ptList: &touchList)
            onErase(linePath: linePath)
        }
        else {
            let linePath = generateLine(ptList: &touchList)
            onPaint(linePath: linePath)
        }            
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                   
        self.touchList.removeAll()
        flattenLayers(drawingLayer:self.drawingLayer, max: 0)
    }
}

extension PainterView {
                  
    func onPaint(linePath: UIBezierPath) {
                
        let paintingLayer = MyDrawingShapeLayer()
        paintingLayer.path = linePath.cgPath
        
        paintingLayer.contentsScale = UIScreen.main.scale
        paintingLayer.fillColor = UIColor.blue.cgColor
        paintingLayer.strokeColor = UIColor.blue.cgColor
        paintingLayer.opacity = 1.0
        paintingLayer.lineWidth = lineWidth
        paintingLayer.lineCap = .round
         
        self.drawingLayer.addSublayer(paintingLayer)
        flattenLayers(drawingLayer:self.drawingLayer, max: 50)
    }
    
    func onErase(linePath: UIBezierPath) {
        
        let render = UIGraphicsImageRenderer(bounds: self.bounds)

        let img = render.image { (ctx) in

            drawingLayer.render(in: ctx.cgContext)
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(lineWidth)
            ctx.cgContext.setBlendMode(.clear)

            ctx.cgContext.addPath(linePath.cgPath)
            ctx.cgContext.strokePath()
        }

        drawingLayer.contents = img.cgImage
    }
    
    func flattenLayers(drawingLayer: CALayer, max: Int) {
        
        guard drawingLayer.sublayers != nil else { return }
        guard drawingLayer.sublayers!.count > max else { return }
        
        let render = UIGraphicsImageRenderer(bounds: self.frame)
        let img = render.image { (ctx) in
            
            drawingLayer.render(in: ctx.cgContext)
        }
        
        drawingLayer.contents = img.cgImage
    }
        
    func removeAllSublayers(_ layer: CALayer) {
        
        guard let subLayers = layer.sublayers else { return }
        
        for subLayer in subLayers {
            if subLayer is MyDrawingShapeLayer {
                subLayer.removeFromSuperlayer()
            }
        }
        
    }
}

extension PainterView {
    
    func generateLine(ptList: inout [CGPoint]) -> UIBezierPath {

        let linePath = UIBezierPath()
        
        while ptList.count > 3 {
            
            let secondPt = ptList[0]
            let firstPt = ptList[1]
            let endPt = ptList[2]

            let midFirst = midPoint(p1: firstPt, p2: secondPt)
            let midSecond = midPoint(p1: endPt, p2: firstPt)
            
            let paintingLayer = CAShapeLayer()
            
            paintingLayer.contentsScale = UIScreen.main.scale
            linePath.move(to: midFirst)
            linePath.addQuadCurve(to: midSecond, controlPoint: firstPt)
            
            ptList.removeFirst()
        }
        
        return linePath
    }
    
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
}

