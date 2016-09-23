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

    var initializationHandler: ((UIDatePicker, UIDatePicker) -> Void)!
    var completionHandler: ((Date, Date) -> Void)!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializationHandler(beginDatePicker, endDatePicker)

        datePickerBeginValue(self)
        datePickerEndValue(self)
    }

    // MARK: User Interaction

    @IBAction func datePickerBeginValue(_ sender: AnyObject) {
        beginDetailLabel.text = localizedStringFromDate(beginDatePicker.date)
    }

    @IBAction func datePickerEndValue(_ sender: AnyObject) {
        endDetailLabel.text = localizedStringFromDate(endDatePicker.date)
    }

    @IBAction func submitChangesAction(_ sender: AnyObject) {

        // Begin Time > End Time
        if beginDatePicker.date > endDatePicker.date {
            Popup.showDatesReversed(self) {
                let tmpSwap = self.beginDatePicker.date
                self.beginDatePicker.date = self.endDatePicker.date
                self.endDatePicker.date = tmpSwap
            }
            return
        }

        // Begin Day != End Day
        if !beginDatePicker.date.compareWithoutTime(endDatePicker.date) {
            Popup.showWorkMoreThan24h(self)
            return
        }

        completionHandler(beginDatePicker.date, endDatePicker.date)
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: Additional Helpers

    func localizedStringFromDate(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    }
}
