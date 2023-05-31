//
//  AccountViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/27/22.
//

import Combine
import Foundation

/// ViewModel for the account page of the app.
/// It handles the signing in of users, registering and unregistering
/// for KronoX events, and booking and unbooking of resources.
final class AccountViewModel: ObservableObject {
    let viewModelFactory: ViewModelFactory = .shared
    let dummyDataFactory: DummyDataFactory = .init()
    
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var schoolManager: SchoolManager
    
    @Published var authSchoolId: Int = -1
    @Published var inAppReview: Bool = false
    @Published var schoolName: String = ""
    @Published var status: AccountViewStatus = .loading
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var userBookings: Response.KronoxUserBookings? = nil
    @Published var registeredEventSectionState: GenericPageStatus = .loading
    @Published var bookingSectionState: GenericPageStatus = .loading
    @Published var error: Response.ErrorMessage? = nil
    @Published var resourceDetailsSheetModel: ResourceDetailSheetModel? = nil
    @Published var examDetailSheetModel: ExamDetailSheetModel? = nil
    
    private var resourceSectionDataTask: URLSessionDataTask? = nil
    private var eventSectionDataTask: URLSessionDataTask? = nil
    private let toastFactory: ToastFactory = ToastFactory.shared
    
    var userDisplayName: String? {
        return userController.user?.name
    }
    
    var username: String? {
        return userController.user?.username
    }
    
    var autoSignupEnabled: Bool {
        return userController.autoSignup
    }
    
    /// AccountViewModel is responsible for instantiating
    /// the viewmodel used in its child views it navigates to
    lazy var resourceViewModel: ResourceViewModel = viewModelFactory.makeViewModelResource()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setUpDataPublishers()
        Task {
            if self.userController.autoSignup {
                await self.registerAutoSignup()
            }
        }
    }
    
    func setUpDataPublishers() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let authStatusPublisher = self.userController.$authStatus
            let schoolIdPublisher = self.preferenceService.$authSchoolId
            let inAppReviewPublisher = self.preferenceService.$inAppReview
            
            Publishers.CombineLatest3(authStatusPublisher, schoolIdPublisher, inAppReviewPublisher)
                .receive(on: DispatchQueue.main)
                .sink { authStatus, authSchoolId, _ in
                    switch authStatus {
                    case .authorized:
                        self.authSchoolId = authSchoolId
                        self.schoolName = self.schoolManager
                            .getSchools().first(where: { $0.id == authSchoolId })?.name ?? ""
                        Task {
                            await self.getUserEventsForSection()
                            await self.getUserBookingsForSection()
                        }
                        self.status = .authenticated
                    case .unAuthorized:
                        self.status = .unAuthenticated
                    case .loading:
                        self.status = .loading
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    func removeUserBooking(where id: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.notificationManager.cancelNotification(for: id)
            self.userBookings?.removeAll { $0.id == id }
        }
    }
    
    // This is a caching approach to avoid a network call after user
    // unregisters for an event in account page, and instead modify it in place,
    // since network errors can occur.
    func removeUserEvent(where id: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            if var mutRegisteredEvents = self.completeUserEvent?.registeredEvents,
               var mutUnregisteredEvents = self.completeUserEvent?.unregisteredEvents
            {
                // Find subject in current struct
                let eventRemoved = mutRegisteredEvents.first {
                    $0.eventId == id
                }
                // Add to new array
                if let eventRemoved = eventRemoved {
                    mutUnregisteredEvents.append(eventRemoved)
                }
                mutRegisteredEvents.removeAll {
                    $0.eventId == id
                }
                DispatchQueue.main.async {
                    // Rebuild user events
                    self.completeUserEvent = Response.KronoxCompleteUserEvent(
                        upcomingEvents: self.completeUserEvent?.upcomingEvents,
                        registeredEvents: mutRegisteredEvents, // Insert modified events
                        availableEvents: self.completeUserEvent?.availableEvents,
                        unregisteredEvents: mutUnregisteredEvents
                    )
                }
            }
        }
    }
    
    func login(
        authSchoolId: Int,
        username: String,
        password: String
    ) async {
        
        // Check if matching demo user
        let (demoUsername, demoPassword) = getDemoUserCredentials()
        if username == demoUsername && password == demoPassword {
            do {
                try await userController.loginDemo(username: username, password: password)
                preferenceService.setInAppReview(value: true)
            } catch {
                AppLogger.shared.critical("Could not sign in App Review Team")
            }
        }
        
        do {
            try await userController.logIn(authSchoolId: authSchoolId, username: username, password: password)
            if let username = userController.user?.username {
                AppController.shared.toast = toastFactory.logInSuccess(as: username)
            }
        } catch {
            AppLogger.shared.critical("Failed to log in user")
            AppController.shared.toast = toastFactory.logInFailed()
        }
    }
    
    func setDefaultAuthSchool(schoolId: Int) {
        preferenceService.setAuthSchool(id: schoolId)
    }
    
    // Retrieve user events for resource section
    func getUserEventsForSection() async {
        DispatchQueue.main.async { [weak self] in
            self?.registeredEventSectionState = .loading
        }
        
        do {
            let request = Endpoint.userEvents(schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                // TODO: Handle error
                return
            }
            let events: Response.KronoxCompleteUserEvent? = try await kronoxManager.get(request, refreshToken: refreshToken.value)
            DispatchQueue.main.async { [weak self] in
                self?.completeUserEvent = events
                self?.registeredEventSectionState = .loaded
            }
        } catch (let error) {
            AppLogger.shared.critical("Could not get user events: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.registeredEventSectionState = .error
            }
        }
    }

    func getUserBookingsForSection() async {
        DispatchQueue.main.async {
            self.bookingSectionState = .loading
        }
        
        do {
            let request = Endpoint.userBookings(schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                // TODO: Handle error
                return
            }
            let bookings: Response.KronoxUserBookings = try await kronoxManager.get(request, refreshToken: refreshToken.value)
            DispatchQueue.main.async {
                self.bookingSectionState = .loaded
                self.userBookings = bookings
            }
            await self.checkNotificationsForUserBookings(bookings: bookings)
        } catch (let error) {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.bookingSectionState = .error
            }
        }
    }
    
    func unregisterForEvent(eventId: String) async {
        do {
            let request = Endpoint.unregisterEvent(eventId: eventId, schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                // TODO: Handle error
                return
            }
            let _ : Response.Empty = try await kronoxManager.put(request, refreshToken: refreshToken.value, body: Request.Empty())
            DispatchQueue.main.async {
                self.registeredEventSectionState = .loaded
            }
        } catch (let error) {
            AppLogger.shared.critical("Failed to unregister from event: \(error)")
            // TODO: Add toast
            DispatchQueue.main.async {
                self.registeredEventSectionState = .error
            }
        }
    }
    
    func toggleAutoSignup(value: Bool) {
        userController.autoSignup = value
        if value {
            Task {
                await registerAutoSignup()
                await getUserEventsForSection()
            }
        }
    }
    
    func checkNotificationsForUserBookings(bookings: Response.KronoxUserBookings? = nil) async {
        AppLogger.shared.debug("Checking for notifications to set for user booked resources ...")
        if let userBookings = bookings {
            scheduleBookingNotifications(for: userBookings)
            return
        }
        
        do {
            let request = Endpoint.userBookings(schoolId: String(authSchoolId))
            guard let refreshToken = userController.refreshToken else {
                // TODO: Handle error
                return
            }
            let bookings: Response.KronoxUserBookings = try await kronoxManager.get(request, refreshToken: refreshToken.value)
            self.scheduleBookingNotifications(for: bookings)
        } catch (let error) {
            AppLogger.shared.debug("\(error)")
            DispatchQueue.main.async {
                self.bookingSectionState = .error
            }
        }
    }
}
