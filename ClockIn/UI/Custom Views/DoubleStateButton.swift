//
//  DoubleStateButton.swift
//  ClockIn
//
//  Created by Julien Colin on 09/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class DoubleStateButton: MultipleStatesButton {

    var titles = ["Check In", "Check Out"]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDoubleStateButton()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDoubleStateButton()
    }
    
    func setupDoubleStateButton() {
        delegate = self
        super.reloadData()
    }
    
}

extension DoubleStateButton: MultipleStatesButtonDelegate {

    func multipleStatesButton(button: MultipleStatesButton, titleForState state: Int) -> String {
        return titles[state]
    }
    
    func numberOfStatesInButton(button: MultipleStatesButton) -> Int {
        return titles.count
    }
    
}


// MARK: Better onTouch animations

extension DoubleStateButton {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.8, 0.8)
        })
        
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: { () -> Void in
                                    self.transform = CGAffineTransformIdentity
            }, completion: nil)
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 6.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: { () -> Void in
                                    self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
}