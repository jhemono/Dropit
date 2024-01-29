//
//  DropitViewController.swift
//  Dropit
//
//  Created by Julien Hémono on 20/05/15.
//  Copyright (c) 2015 Julien Hémono. All rights reserved.
//

import UIKit

class DropitViewController: UIViewController, UIDynamicAnimatorDelegate {

    @IBOutlet weak var gameView: BezierPathsView!
    
    let dropitBehavior = DropitBehavior()
    
    var attachmentBehavior: UIAttachmentBehavior? {
        willSet {
            if let attachment = attachmentBehavior {
                animator.removeBehavior(attachment)
            }
            gameView.setPath(nil, named: PathNames.Attachment)
        }
        didSet {
            if let attachment = attachmentBehavior {
                animator.addBehavior(attachment)
                attachment.action = { [unowned self] in
                    if let attachedView = attachment.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(attachment.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: PathNames.Attachment)
                    }
                }
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let drops = animator.itemsInRect(gameView.bounds) as! [UIView]
        animator.removeBehavior(dropitBehavior)
        for drop in drops {
            let tmp = drop.frame.origin.x
            drop.frame.origin.x = drop.frame.origin.y
            drop.frame.origin.y = tmp
            animator.updateItemUsingCurrentState(drop)
        }
        animator.addBehavior(dropitBehavior)
    }
    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.addBehavior(dropitBehavior)
    }
    
    private struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Stick"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let origin = CGPoint(x: gameView.bounds.midX-barrierSize.width/2, y: gameView.bounds.midY-barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: origin, size: barrierSize))
        
        gameView.setPath(path, named: PathNames.MiddleBarrier)
        
        dropitBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    func removeCompletedRow()
    {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        repeat {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    } else {
                        rowIsComplete = false
                    }
                }
                dropFrame.origin.x += dropSize.width
            }
            if rowIsComplete {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropitBehavior.removeDrop(drop)
        }
    }
    
    var dropsPerRow = 10
    
    var dropSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    
    var lastDrop: UIView?
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.random
        
        dropitBehavior.addDrop(dropView)
        lastDrop = dropView
    }
    
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        switch sender.state {
        case .Began:
            if let viewToAttachTo = lastDrop {
                attachmentBehavior = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
                lastDrop = nil
            }
        case .Changed:
            attachmentBehavior?.anchorPoint = gesturePoint
        case .Ended:
            attachmentBehavior = nil
        default: break
        }
    }
}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 5 {
        case 0 : return UIColor.redColor()
        case 1: return UIColor.greenColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.purpleColor()
        case 4: return UIColor.blueColor()
        default: return UIColor.blackColor()
        }
    }
}
