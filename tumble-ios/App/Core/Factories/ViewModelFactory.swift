//
//  ViewModelFactory.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import SwiftUI

class ViewModelFactory {
    
    static let shared = ViewModelFactory()
    
    @Inject var preferenceService: PreferenceService
    
    @MainActor func makeViewModelParent() -> ParentViewModel { .init() }

    @MainActor func makeViewModelSearch() -> SearchParentView.SearchViewModel { .init() }
    
    @MainActor func makeViewModelHomePage() -> HomeView.HomeViewModel { .init() }
    
    @MainActor func makeViewModelBookmarks() -> BookmarksView.BookmarksViewModel { .init() }
    
    @MainActor func makeViewModelAccountPage() -> AccountPageView.AccountPageViewModel { .init() }
    
    @MainActor func makeViewModelOnBoarding() -> OnBoardingView.OnBoardingViewModel { .init() }
    
    // Special viewmodel important for checking user onboarding in order to change
    // the displayed child view
    @MainActor func makeViewModelRoot() -> RootView.RootViewModel {
            .init(
                userNotOnBoarded: !preferenceService.isKeyPresentInUserDefaults(key: StoreKey.userOnboarded.rawValue))
        }
    // Isolated viewmodel requiring an event and color
    @MainActor func makeViewModelEventDetailsSheet(event: Response.Event, color: Color) -> EventDetailsSheetView.EventDetailsViewModel {
        .init(event: event, color: color)
    }
}
