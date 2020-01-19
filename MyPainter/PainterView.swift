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
        let linePath = generateBezierLine(ptList: &touchPool.listCurrent)
        var touchsMoveLayer: CALayer? = nil
        
        if self.eraseMode {
            touchsMoveLayer = onErase(linePath: linePath)
        }
        else {
            touchsMoveLayer = onPaint(linePath: linePath)
        }
        self.layer.addSublayer(touchsMoveLayer!)
        self.touchsMoveSublayers.append(touchsMoveLayer!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                   
        if self.eraseMode {
            combineLayer(hostingLayer:self.layer)
        }
        else {
            combineLayer(hostingLayer:self.layer)
        }
    }
}

extension PainterView {
                  
    func onPaint(linePath: UIBezierPath) -> CAShapeLayer {
                
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
        
        let paintingLayer = CAShapeLayer()
        paintingLayer.frame = self.layer.frame
        paintingLayer.contents = self.backgroundContents
        
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
    
    func combineLayer(hostingLayer: CALayer) {
        
        guard hostingLayer.sublayers != nil else { return }
        
        // Remove all sublayers generated from func touchsMove, we will redraw them after
        for layer in self.touchsMoveSublayers {
            layer.removeFromSuperlayer()
        }
        self.touchsMoveSublayers.removeAll()
               
        // Redraw all points at a new layer from listHistory
        var aRedrawLayer: CAShapeLayer
        let linePath = generateBezierLine(ptList: &touchPool.listHistory)
        if self.eraseMode {
            aRedrawLayer = onErase(linePath: linePath)
        }
        else {
            aRedrawLayer = onPaint(linePath: linePath)
        }
        self.layer.addSublayer(aRedrawLayer)
        self.touchPool.removeAll()        
    }
        
    func removeAllSublayers(_ layer: CALayer) {
        
        guard let subLayers = layer.sublayers else { return }
        subLayers.forEach {
            $0.removeFromSuperlayer()
        }
    }
}

extension PainterView {
    
    func generateBezierLine(ptList: inout [CGPoint]) -> UIBezierPath {

        let linePath = UIBezierPath()
        
        while ptList.available {
            guard let (ptFirst, ptSecond, ptEnd) = ptList.getFirstThreePoints(withRemoveFirst: true) else {
                break
            }
            
            let midFirst = midPoint(p1:ptFirst, p2:ptSecond)
            let midSecond = midPoint(p1:ptSecond, p2:ptEnd)

            linePath.move(to: midFirst)
            linePath.addQuadCurve(to: midSecond, controlPoint: ptSecond)
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
