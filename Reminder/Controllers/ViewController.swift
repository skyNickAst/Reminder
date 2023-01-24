//
//  ViewController.swift
//  Reminder
//
//  Created by Nikolai Astakhov on 24.01.2023.
//

import UIKit
import UserNotifications
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    let realm = try! Realm()
    var models: Results<MyReminder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        askNotifications()
        loadData()
    }
    
    func askNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                // App will work correctly
            } else if error != nil {
                print("Error Notify")
            }
        })
    }
    
    @IBAction func didTapAdd() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? AddViewController else { return }
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        vc.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = MyReminder()
                new.title = title
                new.date = date
                new.identifier = "id_\(title)"
                self.saveData(named: new)
                
                self.createNotification(title, body, date)
            }
        }
    }
    
    func createNotification(_ title: String, _ body: String, _ date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = body
        
        let targetDate = date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate), repeats: false)
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Something went wrong")
            }
        }
    }
    
    //MARK: - Realm Data Managing
    
    func saveData(named data: MyReminder) {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("Error in saveCategories func: \(error)")
        }
        self.table.reloadData()
    }
    
    func loadData() {
        models = realm.objects(MyReminder.self)
        self.table.reloadData()
    }
    
    func deleteData(onIndex num: Int) {
        if let taskForDeletion = models?[num] {
            do {
                try realm.write {
                    realm.delete(taskForDeletion)
                }
            } catch { print("Error in deleteData func: \(error)") }
            self.table.reloadData()
        }
    }

}

//MARK: - Table View Delegate and Data Sourse

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.deleteData(onIndex: indexPath.row)
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let date = models?[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "DD MMM YYYY"
        content.text = models?[indexPath.row].title
        content.secondaryText = formatter.string(from: date!)
        cell.contentConfiguration = content
        return cell
    }
}
