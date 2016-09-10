//
//  DoubleStateButton.swift
//  ClockIn
//
//  Created by Julien Colin on 09/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

@objc protocol MultipleStatesButtonDelegate {
    
    optional func multipleStatesButton(button: MultipleStatesButton, titleForState state: Int) -> String
    optional func multipleStatesButton(button: MultipleStatesButton, attributedTitleForState state: Int) -> NSAttributedString
    func numberOfStatesInButton(button: MultipleStatesButton) -> Int
}


class MultipleStatesButton: UIButton {
    
    private var stateTitles: [String] = ["State 0", "State 1", "State 2", "State 3"]
    private var currentState: Int = 0 {
        didSet {
            if let delegate = delegate {
                currentState = currentState % delegate.numberOfStatesInButton(self)
            } else {
                currentState = currentState % stateTitles.count
            }
        }
    }
    
    var delegate: MultipleStatesButtonDelegate?
    
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        reloadData()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        reloadData()
    }
    
    // MARK: UI
    
    func reloadData() {
        
        if let attributedStateTitle = delegate?.multipleStatesButton?(self, attributedTitleForState: currentState) {
            setAttributedTitle(attributedStateTitle, forState: UIControlState.Normal)
            return
        }
        
        if let stateTitle = delegate?.multipleStatesButton?(self, titleForState: currentState) {
            setTitle(stateTitle, forState: UIControlState.Normal)
            return
        }
        
        setTitle(stateTitles[currentState], forState: UIControlState.Normal)
    }
    

    // MARK: Touches Events
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        currentState += 1
        reloadData()
    }
    
}
