//
//  MyReminder.swift
//  Reminder
//
//  Created by Nikolai Astakhov on 25.01.2023.
//

import Foundation
import RealmSwift

class MyReminder: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date? = nil
    @objc dynamic var identifier: String = ""
}
