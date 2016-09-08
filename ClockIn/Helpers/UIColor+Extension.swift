//
//  UIColor+Extension.swift
//  ClockIn
//
//  Created by Julien Colin on 08/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r red: Int, g green: Int, b blue: Int, a alpha: CGFloat = 1.0) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
}