//
//  EditTableViewController.swift
//  ClockIn
//
//  Created by Julien Colin on 06/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController {

    // MARK: Outlets
    
    @IBOutlet weak var beginDetailLabel: UILabel!
    @IBOutlet weak var beginDatePicker: UIDatePicker!
    @IBOutlet weak var endDetailLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!

    @IBAction func datePickerBeginValue(sender: UIDatePicker) {
        datePickerBeginChanged()
    }
    @IBAction func datePickerEndValue(sender: UIDatePicker) {
        datePickerEndChanged()
    }
    
    var initializationHandler: ((UIDatePicker, UIDatePicker)->Void)!
    var completionHandler: ((NSDate, NSDate)->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializationHandler(beginDatePicker, endDatePicker)
        
        datePickerBeginChanged()
        datePickerEndChanged()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            completionHandler(beginDatePicker.date, endDatePicker.date)
        }
    }
    
    func datePickerBeginChanged () {
        beginDetailLabel.text = localizedStringFromDate(beginDatePicker.date)
    }
    
    func datePickerEndChanged () {
        endDetailLabel.text = localizedStringFromDate(endDatePicker.date)
    }
    
    func localizedStringFromDate(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
}
