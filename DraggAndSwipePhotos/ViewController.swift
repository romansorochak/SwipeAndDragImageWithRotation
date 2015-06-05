//
//  ViewController.swift
//  DraggAndSwipePhotos
//
//  Created by super_user on 6/5/15.
//  Copyright (c) 2015 DevCom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let imageNames: [String] = ["1", "2", "3", "4", "5"]
    private var currentImage = 0
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    
    @IBOutlet weak var frontCenterXDraggableConstraint: NSLayoutConstraint!
    @IBOutlet weak var backCenterXDraggableConstraint: NSLayoutConstraint!
    
    private let TIMESTAMP_NEEDS_TO_SWIPE: NSTimeInterval = 0.1
    private var timestampOnBegan: NSTimeInterval = 0
    private var timestampOnEnd: NSTimeInterval = 0
    private var xTouchOnBeganFromCenter: CGFloat = 0
    
    
    // MARK - ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - touch handlers
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            if touch.view == self.frontImageView {
                
                self.timestampOnBegan = touch.timestamp
                println("self.timestampOnBegan - \(self.timestampOnBegan)")
                let xTouch = touch.locationInView(self.view).x
                self.xTouchOnBeganFromCenter = self.view.frame.width / 2 - xTouch
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            if touch.view == self.frontImageView {
                
                let xTouch = touch.locationInView(self.view).x
                let xTouchFromCenter = self.view.frame.width / 2 - xTouch
                let moveOn = xTouchFromCenter - self.xTouchOnBeganFromCenter
                
                if moveOn < 0 { // right
                    
                    self.backImageView.image = self.getNextImage()
                    
                } else { // left
                    
                    self.backImageView.image = self.getPreviousImage()
                }
                
                self.frontCenterXDraggableConstraint.constant = moveOn
                
                let angle = atan2(moveOn, self.frontImageView.frame.height)
                self.frontImageView.transform = CGAffineTransformMakeRotation(angle)
            }
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        if let touch = touches.first as? UITouch {
            if touch.view == self.frontImageView {
                
                self.timestampOnEnd = touch.timestamp
                
                println("self.timestampOnEnd - \(self.timestampOnEnd)")
                
                if self.frontCenterXDraggableConstraint.constant < 0 { // swipe right
                    
                    self.handleSwipeOnDragRight()
                    
                } else { // drag left
                    
                    self.handleSwipeOnDragLeft()
                }
            }
        }
    }
    
    
    // MARK - swipe on drag ended handlers
    
    func handleSwipeOnDragRight() {
        
        if self.isNextImage() == false {
            self.swipeCenter()
        }
        
        let timestampOfTouch = self.timestampOnEnd - self.timestampOnEnd
        let dragPercent = -(self.frontCenterXDraggableConstraint.constant / (self.view.frame.width / 2))
        
        if self.needToSwipeLeftOrRight() {
            
            self.swipeRight()
        } else {
            
            self.swipeCenter()
        }
    }
    
    func handleSwipeOnDragLeft() {
        
        if self.isPreviousImage() == false {
            self.swipeCenter()
        }
        
        if self.needToSwipeLeftOrRight() {
            
            self.swipeLeft()
        } else {
            
            self.swipeCenter()
        }
    }
    
    func needToSwipeLeftOrRight() -> Bool {
        
        let timestampOfTouch = self.timestampOnEnd - self.timestampOnBegan
        let dragPercent = abs(self.frontCenterXDraggableConstraint.constant / (self.view.frame.width / 2))
        
        return (timestampOfTouch <= TIMESTAMP_NEEDS_TO_SWIPE
            &&
            dragPercent > 0.1)
            ||
            dragPercent > 0.6
    }
    
    
    // MARK - swipe animations
    
    func swipeRight() {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.frontCenterXDraggableConstraint.constant = -500
            let angle = atan2(-5000, self.frontImageView.frame.height)
            self.frontImageView.transform = CGAffineTransformMakeRotation(angle)
            self.frontImageView.layoutIfNeeded()
            
            }) { _ in
                
                self.frontImageView.image = self.backImageView.image
                self.backImageView.image = self.goToNextImage()
                
                self.frontCenterXDraggableConstraint.constant = 0
                self.frontImageView.transform = CGAffineTransformMakeRotation(0)
        }
    }
    
    func swipeLeft() {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.frontCenterXDraggableConstraint.constant = 500
            let angle = atan2(5000, self.frontImageView.frame.height)
            self.frontImageView.transform = CGAffineTransformMakeRotation(angle)
            self.frontImageView.layoutIfNeeded()
            
            }) { _ in
                
                self.frontImageView.image = self.backImageView.image
                self.backImageView.image = self.goToPreviousImage()
                
                self.frontCenterXDraggableConstraint.constant = 0
                self.frontImageView.transform = CGAffineTransformMakeRotation(0)
        }
    }
    
    func swipeCenter() {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.frontCenterXDraggableConstraint.constant = 0
            self.frontImageView.transform = CGAffineTransformMakeRotation(0)
            self.frontImageView.layoutIfNeeded()
        })
    }
    
    
    // MARK - images
    
    func isNextImage() -> Bool {
        
        return self.currentImage < imageNames.count - 1
    }
    
    func getNextImage() -> UIImage? {
        
        if self.isNextImage() == false {
            return nil
        }
        
        let imageName = self.imageNames[self.currentImage+1]
        return UIImage(named: imageName)
    }
    
    func goToNextImage() -> UIImage? {
        
        if self.isNextImage() == false {
            return nil
        }
        
        let image = getNextImage()
        self.currentImage++
        
        return image
    }
    
    func isPreviousImage() -> Bool {
        return self.currentImage > 0
    }
    
    func getPreviousImage() -> UIImage? {
        
        if self.isPreviousImage() == false {
            return nil
        }
        
        let imageName = self.imageNames[self.currentImage-1]
        return UIImage(named: imageName)
    }
    
    func goToPreviousImage() -> UIImage? {
        
        if self.isPreviousImage() == false {
            return nil
        }
        
        let image = getPreviousImage()
        self.currentImage--
        
        return image
    }
}

