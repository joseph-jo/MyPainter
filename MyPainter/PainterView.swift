//
//  PainterView.swift
//  PainterExample
//
//  Created by JosephChen on 2019/9/19.
//  Copyright © 2019 JosephChen. All rights reserved.
//

import UIKit

class PainterView: UIView {
    
    var eraseMode = false
    var backgroundContents: CGImage? = nil
    var touchPool = PointListPool()
    var touchsMoveSublayers = [CALayer]()
    let lineWidth: CGFloat = 20
    let maxSublayer: Int = 500
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .scaleAspectFit
        self.layer.contents = UIImage(named: "BackgroundImg")?.cgImage
        self.layer.backgroundColor = UIColor.lightGray.cgColor                  
    }
    
    func captureBackgroundContents() {
        NSLog("\(self.frame)")
        
        // Keep the background img
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let render = UIGraphicsImageRenderer(bounds: self.bounds, format: format)
        
        let img = render.image { (ctx) in

            self.layer.render(in: ctx.cgContext)
        }
        self.backgroundContents = img.cgImage
    }
}

    
extension PainterView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let firstPt = touch.previousLocation(in: self)
        self.touchPool.append(firstPt)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        self.touchPool.append(touch.location(in: self))
        let linePath = generateLine(ptList: &touchPool.listCurrent)
        var touchsMoveLayer: CALayer? = nil
        
        if self.eraseMode {
            touchsMoveLayer = onErase(linePath: linePath)
        }
        else {
            touchsMoveLayer = onPaint(linePath: linePath)
        }
        self.layer.addSublayer(touchsMoveLayer!)
        self.touchsMoveSublayers.append(touchsMoveLayer!)
        flattenLayers(hostingLayer:self.layer, max: maxSublayer)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                   
        if self.eraseMode {
            flattenLayers(hostingLayer:self.layer, max: 0)
        }
        else {
            flattenLayers(hostingLayer:self.layer, max: 0)
        }
    }
}

extension PainterView {
                  
    func onPaint(linePath: UIBezierPath) -> CAShapeLayer {
                
        NSLog("\(#function)")
        let paintingLayer = CAShapeLayer()
        paintingLayer.path = linePath.cgPath
        
        paintingLayer.contentsScale = UIScreen.main.scale
        paintingLayer.fillColor = UIColor.blue.cgColor
        paintingLayer.strokeColor = UIColor.blue.cgColor
        paintingLayer.opacity = 1.0
        paintingLayer.lineWidth = lineWidth
        paintingLayer.lineCap = .round
         
        return paintingLayer
    }
    
    func onErase(linePath: UIBezierPath) -> CAShapeLayer  {
        
        NSLog("\(#function)")
        let paintingLayer = CAShapeLayer()
        paintingLayer.frame = self.layer.frame
        NSLog("\(paintingLayer.frame)")
        paintingLayer.contents = backgroundContents
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = paintingLayer.frame
        maskLayer.lineCap = .round
        maskLayer.path = linePath.cgPath
        maskLayer.lineWidth = lineWidth
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor

        // add mask
        paintingLayer.mask = maskLayer
                  
        return paintingLayer
    }
    
    func flattenLayers(hostingLayer: CALayer, max: Int) {
        
        guard hostingLayer.sublayers != nil else { return }
        guard hostingLayer.sublayers!.count > max else { return }
        
        NSLog("\(#function)")
        
        // Remove all sublayers, we will redraw all points
//        removeAllSublayers(hostingLayer)
        for layer in self.touchsMoveSublayers {
            layer.removeFromSuperlayer()
        }
        self.touchsMoveSublayers.removeAll()
               
        // Redraw all points at a new layer
        NSLog("Redraw Start")
        var aRedrawLayer: CAShapeLayer
        let linePath = generateLine(ptList: &touchPool.listHistory)
        if self.eraseMode {
            aRedrawLayer = onErase(linePath: linePath)
        }
        else {
            aRedrawLayer = onPaint(linePath: linePath)
        }
        self.layer.addSublayer(aRedrawLayer)
        self.touchPool.removeAll()
        NSLog("Redraw End")

//        NSLog("Render Start")

//        let render = UIGraphicsImageRenderer(bounds: self.frame)
//        let img = render.image { (ctx) in
//
//            // To make sure we just render one sublayer
//            NSLog("render subLayers: \(hostingLayer.sublayers!.count)")
//            assert(hostingLayer.sublayers!.count == 1)
//
//            hostingLayer.render(in: ctx.cgContext)
//        }
//        NSLog("Render End")
//        _ = self.saveImage(image: img)
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        hostingLayer.contents = img.cgImage
//        CATransaction.commit()
//        removeAllSublayers(hostingLayer)
    }
        
    func removeAllSublayers(_ layer: CALayer) {
        
        guard let subLayers = layer.sublayers else { return }
        subLayers.forEach {
            $0.removeFromSuperlayer()
        }
    }
}

extension PainterView {
    
    func generateLine(ptList: inout [CGPoint]) -> UIBezierPath {

        let linePath = UIBezierPath()
        
        while ptList.available {
            guard let (secondPt, firstPt, endPt) = ptList.getFirstThreePointsAtCurrent(withRemoveFirst: true) else {
                break
            }
            
            let midFirst = midPoint(p1: firstPt, p2: secondPt)
            let midSecond = midPoint(p1: endPt, p2: firstPt)

            linePath.move(to: midFirst)
            linePath.addQuadCurve(to: midSecond, controlPoint: firstPt)
        }
        
        return linePath
    }
    
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
}

extension PainterView {
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
