//
//  WorkSlot.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import Foundation
import CoreData

class WorkSlot: NSManagedObject {}

class WorkSlotItems {

    var currentJob: String
    
    var sections: [Date] = []
    var items: [[WorkSlot]] = []

    var totalWorked = 0

    init(job: String) {
        self.currentJob = job
    }
    
    func addSection(_ section: Date, items: [WorkSlot]) {
        sections = sections + [section]
        self.items = self.items + [items]

        for item in items {
            if let end = item.end {
                totalWorked += end.minutesFrom(item.begin)
            }
        }
    }

    func totalTimeForSection(_ index: Int) -> Int {
        let items = self.items[index]
        var total = 0

        for item in items {
            if let end = item.end {
                total += end.minutesFrom(item.begin)
            }
        }
        return total
    }
}
