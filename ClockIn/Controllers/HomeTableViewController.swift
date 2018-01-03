//
//  HomeTableViewController.swift
//  ClockIn
//
//  Created by Julien Colin on 05/09/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import AMGCalendarManager
import RealmSwift

extension Array {
    func grouped<T>(by criteria: (Element) -> T) -> [T: [Element]] {
        var groups = [T: [Element]]()
        for element in self {
            let key = criteria(element)
            if groups.keys.contains(key) == false {
                groups[key] = [Element]()
            }
            groups[key]?.append(element)
        }
        return groups
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension Date {
    func toLongFormatString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self).uppercased()
    }
    
}

final class Event: Object {
    @objc dynamic var id: Int = 0 // AutoIncrement existing ?
    @objc dynamic var job: Job?
    
    @objc dynamic var start = Date()
    @objc dynamic var end: Date? = nil
    
    var durationInMinutes: Int {
        return (end ?? Date()).minutesFrom(start)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Job: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = "default"
    
    var events: Results<Event>? {
        return realm?.objects(Event.self)
            .filter(NSPredicate(format: "job == %@", self))
            .sorted(byKeyPath: "start", ascending: false)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


class BaseViewModel {
    
    var currentJob: Job!
    private var jobs: Results<Job>!
    private var events: Results<Event>!

    private let realm: Realm!
    
    var jobsNotEmpty: [Job] {
        return jobs.filter { $0.events?.isEmpty == false }
    }
    
    init() {
        realm = try! Realm()
        
        realmReadAll()
        
        if jobs.count == 0 {
            _ = getJob(name: "default", createIfNotExist: true)
            realmReadAll()
        }
        currentJob = getJob(name: UserDefaults().string(forKey: "currentJob") ?? "default")
    }
    
    func realmReadAll() {
        jobs = realm.objects(Job.self)
        events = realm.objects(Event.self)
        
    }
    
    func changeJob(name: String) {
        self.currentJob = getJob(name: name, createIfNotExist: true)
        realmReadAll()
    }
    
    func clockIn() {
        if let event = currentJob.events!.first, event.end == nil {
            finishEvent(event)
        } else {
            newEvent()
        }
    }
    
    func getJob(name: String, createIfNotExist: Bool = false) -> Job? {
        let matchingJob = jobs.filter({ $0.name == name }).first
        
        if let matchingJob = matchingJob {
            return matchingJob
        }
        return createIfNotExist ? createJob(name: name) : nil
    }
    
    func createJob(name: String = "default") -> Job {
        let job = Job(value: ["id": jobs.count, "name": name])
        try! realm.write() {
            realm.add(job)
        }
        return job
    }
    
    func finishEvent(_ event: Event) {
        try! realm.write() {
            event.end = Date()
        }
        realmReadAll()
    }
    
    func newEvent() {
        var newId = 0
        
        if let lastId = events.sorted(byKeyPath: "id", ascending: false).first?.id {
            newId = lastId + 1
        }

        let event = Event(value: ["id": newId, "job": currentJob, "start": Date()])
        try! realm.write() {
            realm.add(event)
        }
        realmReadAll()
    }
    
    func update(event: Event, start: Date, end: Date) {
        try! realm.write {
            event.start = start
            event.end = end
        }
        realmReadAll()
    }
    
    func delete(event: Event) {
        try! realm.write {
            realm.delete(event)
        }
        realmReadAll()
    }
    
    
}

class HistoryViewModel {

    private var parentViewModel: BaseViewModel
    private var eventsGroupedByDay: [String: [Event]]!
    private var sectionsIndexes: [String]!
    
    init(baseViewModel: BaseViewModel) {
        self.parentViewModel = baseViewModel
        
        refreshWithParent()
    }
    
    func refreshWithParent() {
        guard let resultEvents = parentViewModel.currentJob?.events else { return }
        
        let tmpArray = Array(resultEvents)
        
        sectionsIndexes = tmpArray.map({ $0.start.toLongFormatString() }).unique()
        eventsGroupedByDay = tmpArray.grouped { event in
            return event.start.toLongFormatString()
        }
        
        print(sectionsIndexes)
        print(eventsGroupedByDay)
    }
    
    func clockIn(completion: () -> Void) {
        parentViewModel.clockIn()
        refreshWithParent()
        completion()
    }
    
    func deleteEvent(at indexPath: IndexPath, completion: () -> Void) {
        let event = self.event(at: indexPath)
        parentViewModel.delete(event: event)
        refreshWithParent()
        completion()
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return eventsGroupedByDay[sectionsIndexes[section]]!.count
    }
    
    func numberOfSections() -> Int {
        return sectionsIndexes.count
    }
    
    func event(at indexPath: IndexPath) -> Event {
        return eventsGroupedByDay[sectionsIndexes[indexPath.section]]![indexPath.row]
    }
    
    func changeJob(name: String) {
        parentViewModel.changeJob(name: name)
        refreshWithParent()
    }
    
    var daysWorked: Int {
        return numberOfSections()
    }
    
    func titleForSection(_ section: Int) -> String {
        return sectionsIndexes[section]
    }
    
    func totalTime(inSection section: Int) -> String {
        let totalMinutes = self.totalMinutes(inSection: section)
        
        return "\(totalMinutes / 60) hrs \(totalMinutes % 60) min"
    }

    var totalWorked: Int {
        return sectionsIndexes.enumerated().reduce(0) { (result, e) in
            return result + totalMinutes(inSection: e.offset)
        }
    }
    
    var currentJob: String {
        return parentViewModel.currentJob.name
    }
    
    private func totalMinutes(inSection section: Int) -> Int {
        guard let events = eventsGroupedByDay[sectionsIndexes[section]] else { return 0 }
        return Array(events).reduce(0) { $0 + $1.durationInMinutes }
    }
}

class HomeTableViewController: UIViewController {

    var viewModel = BaseViewModel()
    var historyViewModel: HistoryViewModel!
    
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
        historyViewModel.clockIn {
            self.updateUI()
        }
    }

    fileprivate var jobs = [String]()
    fileprivate var timer: Timer!
    
    var currentJob: String! {
        didSet {
            if currentJob == oldValue {
                return
            }
            
            historyViewModel.changeJob(name: currentJob)
            titleButton.setTitle("Clock In (\(historyViewModel.currentJob))", for: .normal)
            titleButton.updateConstraints()
            UserDefaults().set(currentJob, forKey: "currentJob")
            UserDefaults().synchronize()
            updateUI()
        }
    }

    // MARK: - Lifecycle

    func setupUI() {
        headerView.isUserInteractionEnabled = true
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyViewModel = HistoryViewModel(baseViewModel: viewModel)
        
        tableView.dataSource = self
        tableView.delegate = self

        setupUI()

        titleButton.translatesAutoresizingMaskIntoConstraints = true
        titleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        titleButton.setTitle("Clock In (\(historyViewModel.currentJob))", for: .normal)
        
        updateUI()
        
        print("GO")
        timer = Timer.scheduledTimer(timeInterval: 45.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        
        createCalendarEvents()
    }
    
    func createCalendarEvents() {
        
        AMGCalendarManager.shared.calendarName = "Clock In (\(historyViewModel.currentJob))"
        
        for idxSection in 0..<historyViewModel.numberOfSections() {
            for idxRow in 0..<historyViewModel.numberOfRows(inSection: idxSection) {
                let indexPath = IndexPath(row: idxRow, section: idxSection)
                let event = historyViewModel.event(at: indexPath)
                
                AMGCalendarManager.shared.createEvent(completion: { (e) in
                    guard let e = e else { return }
                    
                    e.startDate = event.start
                    e.endDate = event.end ?? event.start.addingTimeInterval(1) // 1 hour
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    
                    e.title = formatter.string(from: event.start).uppercased()
                    e.notes = "Notes \(event)"
                    e.timeZone = TimeZone.current
                    
                    
                    AMGCalendarManager.shared.saveEvent(event: e, span: .thisEvent, completion: { (error) in
                        print(error)
                    })
                })
            }
        }
        AMGCalendarManager.shared.getAllEvents(completion: { (error, events) in
            print(error)
            print(events)
        })
    }
    
    @objc func timerRunning() {
        print("reload \(Date())")
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return (sender as? CustomTableViewCell)?.event.end != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let vc = segue.destination as? EditTableViewController,
            let cell = sender as? CustomTableViewCell {

            vc.initializationHandler = { (beginDatePicker, endDatePicker) in
                beginDatePicker.date = cell.event.start
                endDatePicker.date = cell.event.end!
            }

            vc.completionHandler = { (beginDate, endDate) in
                self.viewModel.update(event: cell.event, start: beginDate, end: endDate)
                // TODO change with historyViewModel + refreshFromParent()
                self.updateUI()
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
        
        viewModel.jobsNotEmpty.forEach {
            vc.addAction(UIAlertAction(title: $0.name, style: .default, handler: { (action) in
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
            
            self.historyViewModel.changeJob(name: newJob)
            
            self.currentJob = newJob
        }))
        
        present(vc, animated: true, completion: nil)
    }

    // MARK: - UI Update

    fileprivate func updateUI() {
        updateHeaderBar()
        tableView.reloadData()
    }

    fileprivate func updateHeaderBar() {
        headerTotalTimeButton.minutesWorked = historyViewModel.totalWorked
        updateDaysWorkedLabel()
    }

    fileprivate func updateDaysWorkedLabel() {
        let daysWorked = historyViewModel.daysWorked

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        style.lineBreakMode = NSLineBreakMode.byWordWrapping

        let font = UIFont.boldSystemFont(ofSize: 15)

        let dict = [NSAttributedStringKey.foregroundColor: 🖌.materialRedColor, NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: style]

        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "\(daysWorked)", attributes: dict))

        headerTotalDaysLabel.attributedText = attributedString
    }
}

// MARK: - Table view

extension HomeTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyViewModel.numberOfRows(inSection: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return historyViewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let data = historyViewModel.event(at: indexPath)

        cell.setup()
        cell.event = data

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            historyViewModel.deleteEvent(at: indexPath) {
                self.updateUI()
            }
        }
    }
}

extension HomeTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeaderDateLabel.text = historyViewModel.titleForSection(section)
        sectionHeaderTimeLabel.text = historyViewModel.totalTime(inSection: section)

        let view = sectionHeaderView.copyView() as! UIView
        return view
    }
}
