//
//  PointListPool.swift
//  MyPainter
//
//  Created by Joseph Chen on 2020/1/17.
//  Copyright © 2020 Joseph Chen. All rights reserved.
//

import UIKit

class PointListPool: NSObject {
    
    var listCurrent = [CGPoint]()
    var listHistory = [CGPoint]()
    
    func append(_ pt: CGPoint) {
        self.listCurrent.append(pt)
        self.listHistory.append(pt)
    }
        
    func removeAll() {
        self.listCurrent.removeAll()
        self.listHistory.removeAll()
    }
}

extension Array {
    
    var available: Bool {
        get {
            return self.count >= 3
        }
    }
    
    mutating func getFirstThreePointsAtCurrent(withRemoveFirst removeFirst: Bool) -> (CGPoint, CGPoint, CGPoint)? {
        
        if self.available == false {
            return nil
        }
        
        let pt1 = self[0] as! CGPoint
        let pt2 = self[1] as! CGPoint
        let pt3 = self[2] as! CGPoint
        
        if removeFirst {
            self.removeFirst()
        }
        
        return (pt1, pt2, pt3)
    }
}
