//
//  EventDetailsView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsSheet: View {
    @ObservedObject var viewModel: EventDetailsSheetViewModel
    @State var presentColorPicker: Bool = false
        
    var body: some View {
        VStack {
            DraggingPill()
            SheetTitle(title: NSLocalizedString("Details", comment: ""))
            ScrollView(showsIndicators: false) {
                EventDetailsCard(
                    parentViewModel: viewModel,
                    openColorPicker: openColorPicker,
                    event: viewModel.event,
                    color: viewModel.color
                )
                EventDetailsBody(event: viewModel.event)
                Spacer()
            }
            .background(Color.background)
            .background(
                ColorPicker(
                    NSLocalizedString("Select course color", comment: ""),
                    selection: $viewModel.color, supportsOpacity: false)
                .labelsHidden().opacity(0)
            )
            .onDisappear(perform: {
                viewModel.updateCourseColor()
                AppController.shared.eventSheet = nil
            })
        }
        .background(Color.background)
    }
    
    func openColorPicker() {
        UIColorWellHelper.helper.execute?()
    }
}
