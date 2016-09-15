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

    @IBAction func datePickerBeginValue(_ sender: UIDatePicker) {
        datePickerBeginChanged()
    }

    @IBAction func datePickerEndValue(_ sender: UIDatePicker) {
        datePickerEndChanged()
    }

    @IBAction func submitChangesAction(_ sender: AnyObject) {

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
        _ = navigationController?.popViewController(animated: true)
    }

    var initializationHandler: ((UIDatePicker, UIDatePicker) -> Void)!
    var completionHandler: ((Date, Date) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        initializationHandler(beginDatePicker, endDatePicker)

        datePickerBeginChanged()
        datePickerEndChanged()
    }

    func datePickerBeginChanged() {
        beginDetailLabel.text = localizedStringFromDate(beginDatePicker.date)
    }

    func datePickerEndChanged() {
        endDetailLabel.text = localizedStringFromDate(endDatePicker.date)
    }

    func localizedStringFromDate(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    }
}
