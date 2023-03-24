//
//  SigningUpExamsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct ExamInstructions: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            UsageCard(titleInstruction: "Account page", bodyInstruction: "Press the account page tab on the bottom", image: "person")
            
            UsageCard(titleInstruction: "Sign in", bodyInstruction: "Sign in with your institution credentials", image: "arrow.up.and.person.rectangle.portrait")
            
            UsageCard(titleInstruction: "Click", bodyInstruction: "Navigate to the event booking page by pressing 'See all'", image: "rectangle.and.hand.point.up.left")
            
            UsageCard(titleInstruction: "Choose", bodyInstruction: "Select an available event to sign up for and press the register button", image: "signature")
            
            UsageCard(titleInstruction: "Done", bodyInstruction: "Now you've signed up for the specified exam, check your email for confirmation", image: "checkmark.seal")
                .padding(.bottom, 55)
        }
    }
}

struct SigningUpExamsView_Previews: PreviewProvider {
    static var previews: some View {
        ExamInstructions()
    }
}
