//
//  User.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOverview: View {
    
    @ObservedObject var viewModel: AccountViewModel
        
    @State private var collapsedHeader: Bool = false
    @State private var toast: Toast? = nil
    
    var body: some View {
        VStack {
            HStack {
                if let name = viewModel.userDisplayName,
                   let username = viewModel.username {
                    UserAvatar(name: name, collapsedHeader: $collapsedHeader)
                    VStack (alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.system(size: collapsedHeader ? 20 : 22, weight: .semibold))
                        if !collapsedHeader {
                            Text(username)
                                .font(.system(size: 16, weight: .regular))
                            Text(viewModel.schoolName)
                                .font(.system(size: 16, weight: .regular))
                                .padding(.top, 10)
                        }
                    }
                    .padding(10)
                }
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
                .foregroundColor(.onBackground)
                .padding(.horizontal, 15)
            Resources(
                parentViewModel: viewModel,
                getResourcesAndEvents: getResourcesAndEvents,
                createToast: createToast,
                collapsedHeader: $collapsedHeader
            )
        }
        .background(Color.background)
        .toastView(toast: $toast)
    }
    
    fileprivate func createToast(toastStyle: ToastStyle, title: String, message: String) -> Void {
        toast = Toast(type: toastStyle, title: title, message: message)
    }
    
    fileprivate func getResourcesAndEvents() -> Void {
        viewModel.getUserBookingsForSection()
        viewModel.getUserEventsForSection()
    }
    
}
