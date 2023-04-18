//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI
import RealmSwift

struct SearchPreview: View {
    
    @ObservedObject var viewModel: SearchPreviewViewModel
    @ObservedResults(Schedule.self) var schedules
    
    let programmeId: String
    
    var body: some View {
        VStack {
            DraggingPill()
            HStack {
                Spacer()
                BookmarkButton(
                    bookmark: bookmark,
                    buttonState: $viewModel.buttonState)
            }
            switch viewModel.status {
            case .loaded:
                SearchPreviewList(
                    viewModel: viewModel
                )
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error:
                if let failure = viewModel.errorMessage {
                    Info(title: failure, image: nil)
                } else {
                    Info(title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
                }
            case .empty:
                Info(title: NSLocalizedString("Schedule seems to be empty", comment: ""), image: nil)
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .center
            )
        .background(Color.background)
        .onAppear {
            viewModel.getSchedule(programmeId: programmeId, schedules: Array(schedules))
        }
    }
    
    func bookmark() -> Void {
        if viewModel.isSaved {
            if let scheduleToRemoveIndex = schedules.firstIndex(where: { $0.scheduleId == viewModel.scheduleId }) {
                $schedules.remove(atOffsets: IndexSet(arrayLiteral: scheduleToRemoveIndex))
            }
        } else {
            let realmSchedule = viewModel.schedule!.toRealmSchedule()
            $schedules.append(realmSchedule)
        }
        viewModel.bookmark(id: programmeId, schedules: Array(schedules))
    }
}

