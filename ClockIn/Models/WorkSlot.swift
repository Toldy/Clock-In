//
//  WorkSlot.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import Foundation
import CoreData


class WorkSlot: NSManagedObject { }


class WorkSlotItems {
    
    var sections: [NSDate] = []
    var items: [[WorkSlot]] = []
    
    var totalWorked = 0
    
    func addSection(section: NSDate, items:[WorkSlot]){
        sections = sections + [section]
        self.items = self.items + [items]
        
        for item in items {
            if let end = item.end {
                totalWorked += end.minutesFrom(item.begin)
            }
        }
    }
}
