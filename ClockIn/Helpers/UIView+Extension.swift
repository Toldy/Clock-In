//
//  UIView+Extension.swift
//  ClockIn
//
//  Created by Julien Colin on 08/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

extension UIView
{
    func copyView() -> AnyObject
    {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}