//
//  HomeTableViewController.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import CoreData

class 🖌 {
    
    static var lightGreyColor = UIColor(r: 33, g: 33, b: 33, a: 0.5)
    static var materialRedColor = UIColor(r: 244, g: 67, b: 54)
    static var materialBlueColor = UIColor(r: 63, g: 81, b: 181)
}

class HomeTableViewController: UIViewController {

    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet var sectionHeaderView: UIView!
    @IBOutlet weak var sectionStatsLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBAction func actionCheck(sender: AnyObject) {
        if let workSlot = workSlotItems.items[0].first where workSlot.end == nil {
            workSlot.end = NSDate()
            coreDataUpdate(workSlot)
        } else {
            coreDataCreate(NSDate())
        }
        
    }
    
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private var workSlotItems = WorkSlotItems()
    
    
    // MARK: - Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupUI()

        coreDataRead()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return (sender as? CustomTableViewCell)?.workSlot.end != nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let vc = segue.destinationViewController as? EditTableViewController,
            let cell = sender as? CustomTableViewCell {
            
            vc.initializationHandler = { (beginDatePicker, endDatePicker)  in
                beginDatePicker.date = cell.workSlot.begin
                endDatePicker.date = cell.workSlot.end!
            }
            
            vc.completionHandler = { (beginDate, endDate)  in
                let workSlot = cell.workSlot
                workSlot.begin = beginDate
                workSlot.end = endDate
                
                self.coreDataUpdate(workSlot)
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - UI Update
    
    func updateUI() {
        updateStats()
        updateCheckButton()
    }
    
    func setupUI() {
        headerView.userInteractionEnabled = true
        navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func updateCheckButton() {
        if let _ = workSlotItems.items[0][0].end {
            checkButton.setTitle("Check In", forState: UIControlState.Normal)
        } else {
        checkButton.setTitle("Check Out", forState: UIControlState.Normal)
        }
    }
    
    func updateStats() {
        setStatsToLabel(workSlotItems.totalWorked, to: statsLabel, normalColor: 🖌.lightGreyColor, highlighColor: 🖌.materialRedColor, prefix: "Total : ")
    }
    
    func setStatsToLabel(minutesWorked: Int, to label : UILabel, normalColor: UIColor, highlighColor: UIColor, prefix: String = "", suffix: String = "") {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Center
        style.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let font1 = UIFont.systemFontOfSize(15)
        let font2 = UIFont.boldSystemFontOfSize(15)
        let dict1 = [NSForegroundColorAttributeName:normalColor, NSFontAttributeName: font1, NSParagraphStyleAttributeName: style]
        let dict2 = [NSForegroundColorAttributeName:highlighColor, NSFontAttributeName: font2, NSParagraphStyleAttributeName: style]
        let signInString = NSMutableAttributedString()
        signInString.appendAttributedString(NSAttributedString(string: prefix, attributes: dict1))
        signInString.appendAttributedString(NSAttributedString(string: "\(minutesWorked / 60)", attributes: dict2))
        signInString.appendAttributedString(NSAttributedString(string: "h ", attributes: dict1))
        signInString.appendAttributedString(NSAttributedString(string: "\(minutesWorked % 60)", attributes: dict2))
        signInString.appendAttributedString(NSAttributedString(string: "m", attributes: dict1))
        signInString.appendAttributedString(NSAttributedString(string: suffix, attributes: dict1))
        label.attributedText = signInString
    }
    
    func getDayMonthYearOfDate(date: NSDate) -> (Int, Int, Int) {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        return (components.year, components.month, components.day)
    }

    func compareOnlyDayMonthYear(first: NSDate, second: NSDate) -> Bool {
        return getDayMonthYearOfDate(first) == getDayMonthYearOfDate(second)
    }
    
    
    // MARK: - Core Data
    
    func coreDataRead() {
        let fetchRequest = NSFetchRequest(entityName: "WorkSlot")
        do {
            
            if var results = try self.managedObjectContext.executeFetchRequest(fetchRequest).sort({ $0.begin > $1.begin }) as? [WorkSlot] {
                workSlotItems = WorkSlotItems()
                while let first = results.first {
                    let items = results.filter { compareOnlyDayMonthYear($0.begin, second: first.begin) }
                    workSlotItems.addSection(first.begin, items: items)
                    results.removeObjectsInArray(items)
                }
            }
            updateUI()
            tableView.reloadData()
            
        } catch { print("LEL. Did you really got an error ?!") }
    }
    
    func coreDataUpdate(workSlot: WorkSlot) {
        do {
            
            try workSlot.managedObjectContext?.save()
            coreDataRead()
            
        } catch { print("LEL. Did you really got an error ?!") }
    }
    
    func coreDataDelete(workSlot: WorkSlot) {
        self.managedObjectContext.deleteObject(workSlot)
        do {
            
            try self.managedObjectContext.save()
            coreDataRead()
            
        } catch { print("LEL. Did you really got an error ?!") }
    }
    
    func coreDataCreate(begin: NSDate, end: NSDate? = nil) {
        let newSlot = NSEntityDescription.insertNewObjectForEntityForName("WorkSlot", inManagedObjectContext: self.managedObjectContext) as! WorkSlot
        newSlot.begin = begin
        newSlot.end = end
        
        coreDataRead()
    }
    
}


// MARK: - Table view

extension HomeTableViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workSlotItems.items[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return workSlotItems.sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        let data = workSlotItems.items[indexPath.section][indexPath.row]

        cell.setup()
        cell.workSlot = data
        
        return cell
    }
}


extension HomeTableViewController : UITableViewDelegate {

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            coreDataDelete(workSlotItems.items[indexPath.section][indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let dataForTitle = workSlotItems.sections[section]
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        
        sectionHeaderLabel.text = formatter.stringFromDate(dataForTitle)
        setStatsToLabel(workSlotItems.totalTimeForSection(section), to: sectionStatsLabel, normalColor: 🖌.lightGreyColor, highlighColor: 🖌.materialBlueColor, prefix: "(", suffix: ")")
        
        let view = sectionHeaderView.copyView() as! UIView
        return view
    }
    
}
