//
//  Date+Extension.swift
//  ClockIn
//
//  Created by Julien Colin on 06/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import Foundation

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

extension Date {

    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }

    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }

    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }

    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }

    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }

    func minutesFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }

    func secondsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }

    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date) > 0 { return "\(yearsFrom(date))y" }
        if monthsFrom(date) > 0 { return "\(monthsFrom(date))M" }
        if weeksFrom(date) > 0 { return "\(weeksFrom(date))w" }
        if daysFrom(date) > 0 { return "\(daysFrom(date))d" }
        if hoursFrom(date) > 0 { return "\(hoursFrom(date))h" }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

private func getDayMonthYearOfDate(_ date: Date) -> (Int, Int, Int) {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day, .month, .year], from: date)
    return (components.year!, components.month!, components.day!)
}

extension Date {

    // Compare without taking care of the time
    func compareWithoutTime(_ rhs: Date) -> Bool {
        return self == rhs || getDayMonthYearOfDate(self) == getDayMonthYearOfDate(rhs)
    }
}
