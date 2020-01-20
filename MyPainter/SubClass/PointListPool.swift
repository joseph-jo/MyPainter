//
//  PointListPool.swift
//  MyPainter
//
//  Created by Joseph Chen on 2020/1/17.
//  Copyright © 2020 Joseph Chen. All rights reserved.
//

import UIKit

class PointListPool: NSObject {
     
    var listDrawing = NSMutableArray()
    var listHistory = NSMutableArray()
    
    func append(_ pt: CGPoint) {
        self.listDrawing.add(pt)
        self.listHistory.add(pt)
    }
        
    func removeAll() {
        self.listDrawing.removeAllObjects()
        self.listHistory.removeAllObjects()
    }
    
}

extension PointListPool {
    
    enum ListType {
        case drawing
        case history
    }
    
    func generateBezierLine(type: ListType) -> UIBezierPath {

        var ptList: NSMutableArray
        if type == .drawing {
            ptList = self.listDrawing
        }
        else {
            ptList = self.listHistory
        }
         
        let linePath = UIBezierPath()
        while ptList.available {
            
            guard let (ptFirst, ptSecond, ptEnd) = ptList.getFirstThreePoints() else { break }
            
            let midFirst = midPoint(p1:ptFirst, p2:ptSecond)
            let midSecond = midPoint(p1:ptSecond, p2:ptEnd)

            linePath.move(to: midFirst)
            linePath.addQuadCurve(to: midSecond, controlPoint: ptSecond)
            
            ptList.removeFirst()
        }
                
        return linePath
    }
    
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
}

extension NSMutableArray {
    
    var available: Bool {
        get {
            return self.count >= 3
        }
    }
    
    func removeFirst() {
        
        self.removeObject(at: 0)
    }
    
    func getFirstThreePoints() -> (CGPoint, CGPoint, CGPoint)? {
        
        if self.available == false {
            return nil
        }
        
        let pt1 = self[0] as! CGPoint
        let pt2 = self[1] as! CGPoint
        let pt3 = self[2] as! CGPoint
                
        return (pt1, pt2, pt3)
    }
}
