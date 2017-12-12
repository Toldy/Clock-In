//
//  HomeTableViewController.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import CoreData
import AMGCalendarManager

class HomeTableViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTotalTimeButton: HoursWorkedButton!
    @IBOutlet weak var headerTotalDaysLabel: UILabel!
    @IBOutlet weak var headerCheckButton: DoubleStateButton!

    @IBOutlet var sectionHeaderView: UIView!
    @IBOutlet weak var sectionHeaderDateLabel: UILabel!
    @IBOutlet weak var sectionHeaderTimeLabel: UILabel!

    @IBAction func actionCheck(_ sender: AnyObject) {
        if let workSlot = workSlotItems.items[safe: 0]?.first, workSlot.end == nil {
            workSlot.end = Date()
            coreDataUpdate(workSlot)
        } else {
            coreDataCreate(begin: Date(), job: currentJob)
        }
    }

    private let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate var workSlotItems: WorkSlotItems!
    fileprivate var jobs = [String]()
    fileprivate var timer: Timer!
    
    var currentJob: String = UserDefaults().string(forKey: "currentJob") ?? "default" {
        didSet {
            if currentJob == oldValue {
                return
            }
            
            self.titleButton.setTitle("Clock In (\(self.currentJob))", for: .normal)
            self.titleButton.updateConstraints()
            self.coreDataRead()
            UserDefaults().set(currentJob, forKey: "currentJob")
            UserDefaults().synchronize()
        }
    }

    // MARK: - Lifecycle

    func setupUI() {
        headerView.isUserInteractionEnabled = true
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        setupUI()

        titleButton.translatesAutoresizingMaskIntoConstraints = true
        titleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        titleButton.setTitle("Clock In (\(currentJob))", for: .normal)
        coreDataRead()
        
        print("GO")
        timer = Timer.scheduledTimer(timeInterval: 45.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        
        toldino()
    }
    
    func toldino() {
        
        AMGCalendarManager.shared.calendarName = "Clock In (\(currentJob))"
        
        for day in workSlotItems.items {
            for event in day {
                AMGCalendarManager.shared.createEvent(completion: { (e) in
                    guard let e = e else { return }
                    
                    e.startDate = event.begin
                    e.endDate = event.end ?? event.begin // 1 hour
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    
                    e.title = formatter.string(from: event.begin).uppercased()
                    e.notes = "Notes \(event)"
                    e.timeZone = TimeZone.current
                    
                    
                    AMGCalendarManager.shared.saveEvent(event: e)
                    
                })
            }
        }
//        AMGCalendarManager.shared.getAllEvents(completion: { (error, events) in
//            print(error)
//            print(events)
//        })
    }
    
    func timerRunning() {
        print("reload \(Date())")
        coreDataRead()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return (sender as? CustomTableViewCell)?.workSlot.end != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let vc = segue.destination as? EditTableViewController,
            let cell = sender as? CustomTableViewCell {

            vc.initializationHandler = { (beginDatePicker, endDatePicker) in
                beginDatePicker.date = cell.workSlot.begin as Date
                endDatePicker.date = cell.workSlot.end! as Date
            }

            vc.completionHandler = { (beginDate, endDate) in
                let workSlot = cell.workSlot
                workSlot?.begin = beginDate
                workSlot?.end = endDate

                self.coreDataUpdate(workSlot!)
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    @IBAction func switchJob(_ sender: Any) {
        let vc = UIAlertController(title: "Current job",
                                   message: "Change the job to display",
                                   preferredStyle: .actionSheet)
        
        jobs.forEach {
            vc.addAction(UIAlertAction(title: $0, style: .default, handler: { (action) in
                self.currentJob = action.title!
            }))
        }
        vc.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        present(vc, animated: true, completion: nil)
    }

    @IBAction func addJob(_ sender: Any) {
        let vc = UIAlertController(title: "NEW", message: nil, preferredStyle: .alert)
        
        vc.addTextField { (textfield) in
            textfield.placeholder = "Job's name"
        }
        vc.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let newJob = vc.textFields?.first?.text else { return }
            
            self.stringToCoreData(content: "{\"fetchResult\":[{\"job\":\"default\",\"begin\":1473750030,\"end\":1473763411},{\"job\":\"default\",\"begin\":1473790516,\"end\":1473791777.1715069},{\"job\":\"default\",\"begin\":1475687873.437937,\"end\":1475687874.120949},{\"job\":\"infomil\",\"begin\":1512461197,\"end\":1512471944},{\"job\":\"default\",\"begin\":1474458615,\"end\":1474470557},{\"job\":\"default\",\"begin\":1473679389.464047,\"end\":1473696033},{\"job\":\"default\",\"begin\":1473663607,\"end\":1473676512},{\"job\":\"default\",\"begin\":1473247815,\"end\":1473264015},{\"job\":\"default\",\"begin\":1474268441,\"end\":1474281041},{\"job\":\"infomil\",\"begin\":1512478959,\"end\":1512497952},{\"job\":\"default\",\"begin\":1476102811,\"end\":1476107794},{\"job\":\"default\",\"begin\":1473159645,\"end\":1473181253.8230519},{\"job\":\"default\",\"begin\":1473112806,\"end\":1473120007},{\"job\":\"default\",\"begin\":1473795526,\"end\":1473800327},{\"job\":\"default\",\"begin\":1473836403,\"end\":1473839104},{\"job\":\"default\",\"begin\":1474524038,\"end\":1474529386},{\"job\":\"default\",\"begin\":1474442277,\"end\":1474455297.8789749},{\"job\":\"default\",\"begin\":1473075600,\"end\":1473094800},{\"job\":\"default\",\"begin\":1474291834,\"end\":1474302634},{\"job\":\"default\",\"begin\":1473766507,\"end\":1473784989},{\"job\":\"default\",\"begin\":1476083547.701364,\"end\":1476100617},{\"job\":\"default\",\"begin\":1473145494,\"end\":1473155636.101613},{\"job\":\"default\",\"begin\":1473848785,\"end\":1473876329},{\"job\":\"default\",\"begin\":1474354835,\"end\":1474367436},{\"job\":\"default\",\"begin\":1474873803,\"end\":1474888265},{\"job\":\"default\",\"begin\":1473058800,\"end\":1473072000},{\"job\":\"default\",\"begin\":1475651835,\"end\":1475665877},{\"job\":\"default\",\"begin\":1474372495,\"end\":1474394095},{\"job\":\"default\",\"begin\":1473231646,\"end\":1473245867.085242},{\"job\":\"default\",\"begin\":1474284643,\"end\":1474290044},{\"job\":\"infomil\",\"begin\":1512721013,\"end\":1512731989.8475649},{\"job\":\"infomil\",\"begin\":1512548399,\"end\":1512559800},{\"job\":\"infomil\",\"begin\":1512562857,\"end\":1512578337},{\"job\":\"infomil\",\"begin\":1512634410,\"end\":1512644731},{\"job\":\"infomil\",\"begin\":1512652073,\"end\":1512669353},{\"job\":\"infomil\",\"begin\":1512736950,\"end\":1512759092},{\"job\":\"infomil\",\"begin\":1512980456,\"end\":1512990057},{\"job\":\"infomil\",\"begin\":1512992702,\"end\":1513010703},{\"job\":\"infomil\",\"begin\":1513066180,\"end\":1513077162},{\"job\":\"infomil\",\"begin\":1513080590.4707189,\"end\":1513101045.624413},{\"job\":\"Self\",\"begin\":1513107421,\"end\":1513114621}]}")
            
            self.currentJob = newJob
        }))
        
        present(vc, animated: true, completion: nil)
    }

    // MARK: - UI Update

    fileprivate func updateUI() {
        updateHeaderBar()
    }

    fileprivate func updateHeaderBar() {
        headerTotalTimeButton.minutesWorked = workSlotItems.totalWorked
        updateDaysWorkedLabel()
    }

    fileprivate func updateDaysWorkedLabel() {
        let daysWorked = workSlotItems.sections.count

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        style.lineBreakMode = NSLineBreakMode.byWordWrapping

        let font = UIFont.boldSystemFont(ofSize: 15)

        let dict = [NSForegroundColorAttributeName: 🖌.materialRedColor, NSFontAttributeName: font, NSParagraphStyleAttributeName: style]

        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "\(daysWorked)", attributes: dict))

        headerTotalDaysLabel.attributedText = attributedString
    }

    // MARK: - Core Data
    
    func coreDataToString(_ data: [WorkSlot]) -> String {
        let dict = ["fetchResult" : data.map({ $0.dict })]
        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data:data, encoding:.utf8)!
    }
    
    func stringToCoreData(content: String) -> [WorkSlot] {
        if let data = content.data(using: .utf8) {
            do {
                guard let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return [] }
                
                (result["fetchResult"] as? [Any])?.map {
                    let item = $0 as? [String: Any]
                    
                    print(item!["begin"], item!["end"], item!["job"])
                    let b = Date(timeIntervalSince1970: item!["begin"]! as! TimeInterval)
                    var e: Date?
                    if let interval = item!["end"] as? TimeInterval {
                        e = Date(timeIntervalSince1970: interval)
                    }
                    coreDataCreate(begin: b,
                                   end: e,
                                   job: item!["job"]! as! String)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return []
    }
    
    fileprivate func coreDataRead() {
        let fetchRequest = NSFetchRequest<WorkSlot>(entityName: "WorkSlot")
        
        do {
            let fetchResult = try self.managedObjectContext.fetch(fetchRequest)
            
            print(coreDataToString(fetchResult))
            
            // Fetch all jobs
            jobs = Array(Set(fetchResult.flatMap { $0.job }))
            
            // Map workslots
            var results = fetchResult
                .filter { $0.job == currentJob }
                .sorted(by: { $0.begin > $1.begin })
            
            workSlotItems = WorkSlotItems(job: currentJob)
            while let first = results.first {
                let items = results.filter { $0.begin.compareWithoutTime(first.begin) }
                workSlotItems.addSection(first.begin, items: items)
                results.removeObjectsInArray(items)
            }
            updateUI()
            
            
            
            tableView.reloadData()
        } catch { print("LEL. Did you really got an error ?!") }
    }

    fileprivate func coreDataUpdate(_ workSlot: WorkSlot) {
        do {
            try workSlot.managedObjectContext?.save()
            coreDataRead()
        } catch { print("LEL. Did you really got an error ?!") }
    }

    fileprivate func coreDataDelete(_ workSlot: WorkSlot) {
        self.managedObjectContext.delete(workSlot)
        do {

            try self.managedObjectContext.save()
            coreDataRead()
        } catch { print("LEL. Did you really got an error ?!") }
    }

    fileprivate func coreDataCreate(begin: Date, end: Date? = nil, job: String) {
        let newSlot = NSEntityDescription.insertNewObject(forEntityName: "WorkSlot", into: self.managedObjectContext) as! WorkSlot
        newSlot.begin = begin
        newSlot.end = end
        newSlot.job = job

        coreDataRead()
    }
}

// MARK: - Table view

extension HomeTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workSlotItems.items[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return workSlotItems.sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let data = workSlotItems.items[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]

        cell.setup()
        cell.workSlot = data

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataDelete(workSlotItems.items[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
        }
    }
}

extension HomeTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let dataForTitle = workSlotItems.sections[section]

        let formatter = DateFormatter()
        formatter.dateStyle = .long

        sectionHeaderDateLabel.text = formatter.string(from: dataForTitle).uppercased()
        let time = workSlotItems.totalTimeForSection(section)
        sectionHeaderTimeLabel.text = "\(time / 60) hrs \(time % 60) min"

        let view = sectionHeaderView.copyView() as! UIView
        return view
    }
}
