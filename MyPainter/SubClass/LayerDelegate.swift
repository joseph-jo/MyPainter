//
//  LayerDelegate.swift
//  MyPainter
//
//  Created by Joseph Chen on 2020/1/16.
//  Copyright © 2020 Joseph Chen. All rights reserved.
//

import UIKit
    
class LayerDelegate: NSObject, CALayerDelegate {
     
    func display(_ layer: CALayer) {
        NSLog("\(#function)")
        NSLog("display: \(layer)")

        let render = UIGraphicsImageRenderer(bounds: layer.frame)
        let img = render.image { (ctx) in

            layer.render(in: ctx.cgContext)
        }
        removeAllSublayers(layer)
        layer.contents = img.cgImage
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        
        NSLog("\(#function)")
        NSLog("DrawingLayer: \(layer)")
 
        layer.render(in: ctx)

        removeAllSublayers(layer)
    }
    
    func removeAllSublayers(_ layer: CALayer) {
        
        guard let subLayers = layer.sublayers else { return }
        
        for subLayer in subLayers {
            if subLayer is MyDrawingShapeLayer {
                subLayer.removeFromSuperlayer()
            }
        }
        
    }
    
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
