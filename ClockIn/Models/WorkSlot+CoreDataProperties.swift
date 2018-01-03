//
//  WorkSlot+CoreDataProperties.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation

extension WorkSlot {

    @NSManaged var begin: Date!
    @NSManaged var end: Date?
    @NSManaged var job: String!
    
    var dict: [String: Any] {
        return ["begin": begin.timeIntervalSince1970, "end": end?.timeIntervalSince1970, "job": job]
    }
}
