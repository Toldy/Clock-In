//
//  HomeTableViewController.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet var sectionHeaderView: UIView!
    
    @IBAction func actionClockIn(sender: AnyObject) {
        if let workSlot = workSlots.first where workSlot.end == nil {
            workSlot.end = NSDate()
            coreDataUpdate(workSlot)
        } else {
            coreDataCreate(NSDate())
        }
        
        tableView.reloadData()
    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    var sortedWorkSlots: [Int : [WorkSlot]] = [:]
    var workSlots = [WorkSlot]() {
        didSet {
            var t = 0
            for slot in workSlots {
                if let end = slot.end {
                    t += end.minutesFrom(slot.begin)
                }
            }
            totalWorked = t
            sortedWorkSlots = getSortedWorkSlots()
        }
    }
    
    var totalWorked = 0 {
        didSet {
            updateStats()
        }
    }
    
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupUI()

        workSlots = coreDataRead()
        tableView.reloadData()
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
                self.tableView.reloadData()
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - UI Update
    
    func setupUI() {
        navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func updateStats() {
        let style = NSMutableParagraphStyle()
        
        style.alignment = NSTextAlignment.Center
        style.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        let font1 = UIFont.systemFontOfSize(15)
        let font2 = UIFont.boldSystemFontOfSize(15)
        
        let color = UIColor.darkTextColor()
        let color2 = UIColor.redColor()
        
        let dict1 = [NSForegroundColorAttributeName:color, NSFontAttributeName: font1, NSParagraphStyleAttributeName: style]
        let dict2 = [NSForegroundColorAttributeName:color2, NSFontAttributeName: font2, NSParagraphStyleAttributeName: style]
        
        let signInString = NSMutableAttributedString()
        signInString.appendAttributedString(NSAttributedString(string: "Total : ", attributes: dict1))
        signInString.appendAttributedString(NSAttributedString(string: "\(totalWorked/60)", attributes: dict2))
        signInString.appendAttributedString(NSAttributedString(string: "h ", attributes: dict1))
        signInString.appendAttributedString(NSAttributedString(string: "\(totalWorked%60)", attributes: dict2))
        signInString.appendAttributedString(NSAttributedString(string: "m", attributes: dict1))
        
        statsLabel.attributedText = signInString
    }
    
    func getSortedWorkSlots() -> [Int : [WorkSlot]] {
        var sortedWorkSlots: [Int : [WorkSlot]] = [:]
        for slot in workSlots {
            
            let day = getDayMonthYearOfDate(slot.begin)

            if var found = sortedWorkSlots[day] {
                sortedWorkSlots[day]!.append(slot)
            } else {
                sortedWorkSlots[day] = [slot]
            }
        }
        return sortedWorkSlots
    }
   
    
    func getDayMonthYearOfDate(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        return components.year * 10000 + components.month * 100 + components.day
    }
    
    // MARK: - Core Data
    
    func coreDataRead() -> [WorkSlot] {
        let fetchRequest = NSFetchRequest(entityName: "WorkSlot")
        do {
            let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [WorkSlot]
            if  let fetchResults = fetchResults {
                return fetchResults.sort({ $0.begin > $1.begin })
            }
        } catch {
            print("LEL. Did you really got an error ?!")
        }
        return []
    }
    
    func coreDataUpdate(workSlot: WorkSlot) {
        do {
            try workSlot.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
        
        workSlots = coreDataRead()
    }
    
    func coreDataDelete(workSlot: WorkSlot) {
        self.managedObjectContext.deleteObject(workSlot)
        
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
        
        workSlots = coreDataRead()
    }
    
    func coreDataCreate(begin: NSDate, end: NSDate? = nil) {
        let newSlot = NSEntityDescription.insertNewObjectForEntityForName("WorkSlot", inManagedObjectContext: self.managedObjectContext) as! WorkSlot
        newSlot.begin = begin
        newSlot.end = end
        
        workSlots = coreDataRead()
    }
    
}


// MARK: - Table view

extension HomeTableViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(sortedWorkSlots.values)[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedWorkSlots.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        let data = Array(sortedWorkSlots.values)[indexPath.section][indexPath.row]
        
        // Cell Data

        cell.setup()
        cell.workSlot = data
        
        return cell
    }
}


extension HomeTableViewController : UITableViewDelegate {

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            coreDataDelete(Array(sortedWorkSlots.values)[indexPath.section][indexPath.row])
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        sectionHeaderLabel.text = "Day - \(section)"
        
        var view = sectionHeaderView.copyView() as! UIView
        
        return view
    }
    
}

// MARK: - UIView Extensions

extension UIView
{
    func copyView() -> AnyObject
    {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}