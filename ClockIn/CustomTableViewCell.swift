//
//  CustomTableViewCell.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    var workSlot: WorkSlot! {
        didSet {
            beginDate = workSlot.begin
            endDate = workSlot.end
        }
    }
    
    @IBOutlet fileprivate weak var begin: UILabel!
    @IBOutlet fileprivate weak var end: UILabel!
    
    fileprivate var beginDate: Date! {
        didSet {
            begin.text = formatter.string(from: beginDate)
        }
    }
    fileprivate var endDate: Date? {
        didSet {
            guard let endDate_ = endDate else {
                end.text = "-"
                return
            }
            end.text = formatter.string(from: endDate_)
        }
    }
    fileprivate let formatter = DateFormatter()
    
    

    // MARK: Lifecycle
    
    func setup() {
        formatter.dateFormat = "HH:mm"
    }

    
}
