//
//  SideBarSheetType.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation

struct SideBarSheetModel: Identifiable {
    var id: UUID = UUID()
    let sideBarType: SidebarTabType
}
