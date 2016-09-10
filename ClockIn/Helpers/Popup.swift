//
//  Popup.swift
//  ClockIn
//
//  Created by Julien Colin on 10/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit


// Wrapper in case in change the popup library

class Popup {
    
    static func show(viewController: UIViewController, title: String, message: String?) {
        show(viewController, title: title, message: message, okTitle: "Ok")
    }
    
    static func show(viewController: UIViewController, title: String, message: String, okTitle: String, cancelTitle: String, okAction: ((Void) -> Void)?) {
        show(viewController, title: title, message: message, okTitle: okTitle, cancelTitle: cancelTitle, okHandler: okAction, cancelHandler: nil)
    }
    
    
    
    // MARK: - Only change the code here if change the library
    
    static private func show(viewController: UIViewController, title: String, message: String?, okTitle: String, cancelTitle: String? = nil,
                     okHandler: ((Void) -> Void)? = nil, cancelHandler: ((Void) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: okTitle, style: .Default) { (action) in
            okHandler?()
        }
        alertController.addAction(okAction)
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel) { (action) in
                cancelHandler?()
            }
            alertController.addAction(cancelAction)
        }
        
        viewController.presentViewController(alertController, animated: true) {}
    }
}
