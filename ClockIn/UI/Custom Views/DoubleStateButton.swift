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

    func multipleStatesButton(_ button: MultipleStatesButton, titleForState state: Int) -> String {
        return titles[state]
    }

    func numberOfStatesInButton(_ button: MultipleStatesButton) -> Int {
        return titles.count
    }
}

// MARK: Better onTouch animations

extension DoubleStateButton {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        UIView.animate(withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: { () -> Void in
                self.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        UIView.animate(withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: { () -> Void in
                self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
