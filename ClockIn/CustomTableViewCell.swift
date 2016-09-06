//
//  CustomTableViewCell.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
   
    func setup() {
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
    }

    var workSlot: WorkSlot! {
        didSet {
            beginDate = workSlot.begin
            endDate = workSlot.end
        }
    }
    
    // Private 
    
    private var beginDate: NSDate! {
        didSet {
            begin.text = formatter.stringFromDate(beginDate)
        }
    }
    private var endDate: NSDate? {
        didSet {
            guard let endDate_ = endDate else {
                end.text = "_"
                return
            }
            end.text = formatter.stringFromDate(endDate_)
        }
    }
    
    private let formatter = NSDateFormatter()

    @IBOutlet private weak var begin: UILabel!
    @IBOutlet private weak var end: UILabel!
}
