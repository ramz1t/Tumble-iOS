//
//  User.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOverview: View {
    
    @ObservedObject var viewModel: AccountViewModel
        
    @State private var inputImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    let schoolName: String
    let createToast: (ToastStyle, String, String) -> Void
        
    var body: some View {
        VStack {
            ScrollView (showsIndicators: false) {
                HStack {
                    if let name = viewModel.userController.user?.name,
                       let username = viewModel.userController.user?.username {
                        UserAvatar(name: name)
                        VStack (alignment: .leading, spacing: 0) {
                            Text(name)
                                .font(.system(size: 22, weight: .semibold))
                            Text(username)
                                .font(.system(size: 16, weight: .regular))
                            Text(schoolName)
                                .font(.system(size: 16, weight: .regular))
                                .padding(.top, 10)
                        }
                        .padding(10)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(Color.background)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                Divider()
                    .foregroundColor(.onBackground)
                    .padding(.horizontal, 15)
                Resources(parentViewModel: viewModel)
            }
            .refreshable {
                getResourcesAndEvents()
            }
        }
        .onAppear {
            getResourcesAndEvents()
        }
        .background(Color.background)
    }
    
    fileprivate func getResourcesAndEvents() -> Void {
        viewModel.getUserBookingsForSection()
        viewModel.getUserEventsForSection()
    }
    
}
