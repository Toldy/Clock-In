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

    // MARK: - Custom popup here

    static func showDatesReversed(_ viewController: UIViewController, okAction: (() -> Void)?) {
        show(viewController, title: "Ooops 😞", message: "Your begin is set after the end !\nDo you want to swap them ?", okTitle: "YES !", cancelTitle: "Cancel", okHandler: okAction, cancelHandler: nil)
    }

    static func showWorkMoreThan24h(_ viewController: UIViewController) {
        show(viewController, title: "Wow 😮", message: "For real, you cannot work more than 24h in a row...")
    }

    static func show(_ viewController: UIViewController, title: String, message: String?) {
        show(viewController, title: title, message: message, okTitle: "Ok")
    }

    // MARK: - Only change the code here if change the library

    fileprivate static func show(_ viewController: UIViewController, title: String, message: String?, okTitle: String, cancelTitle: String? = nil,
        okHandler: (() -> Void)? = nil, cancelHandler: (() -> Void)? = nil) {

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
