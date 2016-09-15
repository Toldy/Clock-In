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
    
    static func show(_ viewController: UIViewController, title: String, message: String?) {
        show(viewController, title: title, message: message, okTitle: "Ok")
    }
    
    static func show(_ viewController: UIViewController, title: String, message: String, okTitle: String, cancelTitle: String, okAction: ((Void) -> Void)?) {
        show(viewController, title: title, message: message, okTitle: okTitle, cancelTitle: cancelTitle, okHandler: okAction, cancelHandler: nil)
    }
    
    
    
    // MARK: - Only change the code here if change the library
    
    static fileprivate func show(_ viewController: UIViewController, title: String, message: String?, okTitle: String, cancelTitle: String? = nil,
                     okHandler: ((Void) -> Void)? = nil, cancelHandler: ((Void) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okTitle, style: .default) { (action) in
            okHandler?()
        }
        alertController.addAction(okAction)
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
                cancelHandler?()
            }
            alertController.addAction(cancelAction)
        }
        
        viewController.present(alertController, animated: true) {}
    }
}
