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
    
    fileprivate func coreDataRead() {
        let fetchRequest = NSFetchRequest<WorkSlot>(entityName: "WorkSlot")
        
        do {
            let fetchResult = try self.managedObjectContext.fetch(fetchRequest)
            
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
