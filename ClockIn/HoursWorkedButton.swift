//
//  HoursWorkedButton.swift
//  ClockIn
//
//  Created by Julien Colin on 09/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class HoursWorkedButton: MultipleStatesButton {

    var minutesWorked: Int = 0 {
        didSet {
            super.reloadData()
        }
    }

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
    }
}

extension HoursWorkedButton: MultipleStatesButtonDelegate {

    func multipleStatesButton(_ button: MultipleStatesButton, attributedTitleForState state: Int) -> NSAttributedString {

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byWordWrapping

        let font1 = UIFont.systemFont(ofSize: 15)
        let font2 = UIFont.boldSystemFont(ofSize: 15)

        let dict1 = [NSForegroundColorAttributeName: 🖌.lightGreyColor, NSFontAttributeName: font1, NSParagraphStyleAttributeName: style]
        let dict2 = [NSForegroundColorAttributeName: 🖌.materialRedColor, NSFontAttributeName: font2, NSParagraphStyleAttributeName: style]

        let attributedString = NSMutableAttributedString()

        if state == 0 {
            let daysWorked = self.minutesWorked / (60 * 24)
            let hoursWorked = self.minutesWorked % (60 * 24) / 60
            let minutesWorked = self.minutesWorked % 60

            if daysWorked != 0 {
                attributedString.append(NSAttributedString(string: "\(daysWorked)", attributes: dict2))
                attributedString.append(NSAttributedString(string: "j ", attributes: dict1))
            }
            attributedString.append(NSAttributedString(string: String(format: "%02d", hoursWorked), attributes: dict2))
            attributedString.append(NSAttributedString(string: "h ", attributes: dict1))
            attributedString.append(NSAttributedString(string: String(format: "%02d", minutesWorked), attributes: dict2))
            attributedString.append(NSAttributedString(string: "m", attributes: dict1))
        } else {
            let hoursWorked = self.minutesWorked / 60
            let minutesWorked = self.minutesWorked % 60

            attributedString.append(NSAttributedString(string: String(format: "%02d", hoursWorked), attributes: dict2))
            attributedString.append(NSAttributedString(string: "h ", attributes: dict1))
            attributedString.append(NSAttributedString(string: String(format: "%02d", minutesWorked), attributes: dict2))
            attributedString.append(NSAttributedString(string: "m", attributes: dict1))
        }

        return attributedString
    }

    func numberOfStatesInButton(_ button: MultipleStatesButton) -> Int { return 2 }
}
