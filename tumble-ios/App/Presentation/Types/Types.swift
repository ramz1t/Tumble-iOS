//
//  Types.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

// Bottom tab bar
enum TabbarTabType: String {
    case home = "house"
    case bookmarks = "bookmark"
    case account = "person"
    
    static let allValues = [home, bookmarks, account]
    
    var displayName: String {
        switch self {
        case .home:
            return "Home"
        case .bookmarks:
            return "Bookmarks"
        case .account:
            return "Account"
        }
    }
}

enum SidebarTabType: String {
    case notifications = "Notifications" // Opens sheet
    case bookmarks = "Bookmarks"
    case more = "More"
    case school = "Schools" // Opens sheet
    case support = "Support" // Opens sheet
    case logOut = "Log out" // Performs api call
    case logIn = "Log in"
}

enum BookmarksViewType: String {
    case list = "List"
    case calendar = "Calendar"
    
    static let allValues: [BookmarksViewType] = [list, calendar]
}

