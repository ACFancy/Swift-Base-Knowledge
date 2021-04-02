//
//  Profile.swift
//  Landmarks
//
//  Created by Lee Danatech on 2021/3/26.
//

import Foundation

struct Profile {
    var username: String
    var prefersNotifications = true
    var seasonalPhoto = Season.winter
    var goalDate = Date()

    static let `default` = Profile(username: "g-kula")

    enum Season: String, CaseIterable, Identifiable {
        var id: String { return self.rawValue }

        case spring = "🐦"
        case summer = "🌞"
        case autumn = "🍃"
        case winter = "❄️"
    }
}
