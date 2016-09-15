//
//  DoubleStateButton.swift
//  ClockIn
//
//  Created by Julien Colin on 09/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

@objc protocol MultipleStatesButtonDelegate {
    
    @objc optional func multipleStatesButton(_ button: MultipleStatesButton, titleForState state: Int) -> String
    @objc optional func multipleStatesButton(_ button: MultipleStatesButton, attributedTitleForState state: Int) -> NSAttributedString
    func numberOfStatesInButton(_ button: MultipleStatesButton) -> Int
}


class MultipleStatesButton: UIButton {
    
    fileprivate var stateTitles: [String] = ["State 0", "State 1", "State 2", "State 3"]
    fileprivate var currentState: Int = 0 {
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
            setAttributedTitle(attributedStateTitle, for: UIControlState())
            return
        }
        
        if let stateTitle = delegate?.multipleStatesButton?(self, titleForState: currentState) {
            setTitle(stateTitle, for: UIControlState())
            return
        }
        
        setTitle(stateTitles[currentState], for: UIControlState())
    }
    

    // MARK: Touches Events
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        currentState += 1
        reloadData()
    }
    
}
