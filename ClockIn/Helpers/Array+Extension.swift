//
//  Array+Extension.swift
//  ClockIn
//
//  Created by Julien Colin on 08/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}