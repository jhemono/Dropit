//
//  BezierPathsView.swift
//  Dropit
//
//  Created by Julien Hémono on 21/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for path in bezierPaths.values {
            path.stroke()
        }
    }

}
