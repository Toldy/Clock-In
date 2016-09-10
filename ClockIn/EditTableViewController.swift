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
    
    @IBAction func submitChangesAction(sender: AnyObject) {
        
        if beginDatePicker.date > endDatePicker.date {
            Popup.show(self, title: "Ooops 😞", message: "Your begin is set after the end !\nDo you want to swap them ?", okTitle: "YES !", cancelTitle: "Cancel") { (Void) in
                let tmpSwap = self.beginDatePicker.date
                self.beginDatePicker.date = self.endDatePicker.date
                self.endDatePicker.date = tmpSwap
            }
            return
        }
        
        // Begin Day != End Day
        if !beginDatePicker.date.compareWithoutTime(endDatePicker.date) {
            Popup.show(self, title: "Wow 😮", message: "For real, you cannot work more than 24h in a row...")
            return
        }
        
        completionHandler(beginDatePicker.date, endDatePicker.date)
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    var initializationHandler: ((UIDatePicker, UIDatePicker)->Void)!
    var completionHandler: ((NSDate, NSDate)->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializationHandler(beginDatePicker, endDatePicker)
        
        datePickerBeginChanged()
        datePickerEndChanged()
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
