//
//  NotificationService.swift
//  SabahiminBasi
//
//  Created by Mustafa Said Tozluoglu on 21.12.2024.
//

import SwiftUI
import UserNotifications

class NotificationService {
    static let instance = NotificationService() // Singleton
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {
                print("ERROR: \(error)")
            } else {
                print("SUCCESS")
            }
            
        }
    }
}
