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

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTotalTimeButton: HoursWorkedButton!
    @IBOutlet weak var headerTotalDaysLabel: UILabel!
    @IBOutlet weak var headerCheckButton: DoubleStateButton!
    
    @IBOutlet      var sectionHeaderView: UIView!
    @IBOutlet weak var sectionHeaderDateLabel: UILabel!
    @IBOutlet weak var sectionHeaderTimeLabel: UILabel!
    
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
    
    func setupUI() {
        headerView.userInteractionEnabled = true
    }
    
    // MARK: - UI Update
    
    private func updateUI() {
        updateHeaderBar()
    }
    
    private func updateHeaderBar() {
        headerTotalTimeButton.minutesWorked = workSlotItems.totalWorked
        updateDaysWorkedLabel()
    }
        
    private func updateDaysWorkedLabel() {
        let daysWorked = workSlotItems.sections.count
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Left
        style.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        let font = UIFont.boldSystemFontOfSize(15)
        
        let dict = [NSForegroundColorAttributeName:🖌.materialRedColor, NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
        
        let attributedString = NSMutableAttributedString()
        attributedString.appendAttributedString(NSAttributedString(string: "\(daysWorked)", attributes: dict))
        
        headerTotalDaysLabel.attributedText = attributedString
        
    }
    
    
    // MARK: - Core Data
    
    private func coreDataRead() {
        let fetchRequest = NSFetchRequest(entityName: "WorkSlot")
        do {
            
            if var results = try self.managedObjectContext.executeFetchRequest(fetchRequest).sort({ $0.begin > $1.begin }) as? [WorkSlot] {
                workSlotItems = WorkSlotItems()
                while let first = results.first {
                    let items = results.filter { $0.begin.compareWithoutTime(first.begin) }
                    workSlotItems.addSection(first.begin, items: items)
                    results.removeObjectsInArray(items)
                }
            }
            updateUI()
            tableView.reloadData()
            
        } catch { print("LEL. Did you really got an error ?!") }
    }
    
    private func coreDataUpdate(workSlot: WorkSlot) {
        do {
            
            try workSlot.managedObjectContext?.save()
            coreDataRead()
            
        } catch { print("LEL. Did you really got an error ?!") }
    }
    
    private func coreDataDelete(workSlot: WorkSlot) {
        self.managedObjectContext.deleteObject(workSlot)
        do {
            
            try self.managedObjectContext.save()
            coreDataRead()
            
        } catch { print("LEL. Did you really got an error ?!") }
    }
    
    private func coreDataCreate(begin: NSDate, end: NSDate? = nil) {
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
        return 42
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let dataForTitle = workSlotItems.sections[section]
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        
        sectionHeaderDateLabel.text = formatter.stringFromDate(dataForTitle).uppercaseString
        let time = workSlotItems.totalTimeForSection(section)
        sectionHeaderTimeLabel.text = "\(time / 60) hrs \(time % 60) min"
        
        let view = sectionHeaderView.copyView() as! UIView
        return view
    }
    
}
