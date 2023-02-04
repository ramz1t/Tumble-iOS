//
//  EventDetailsBodyView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsBodyView: View {
    
    let event: Response.Event
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Image(systemName: "filemenu.and.cursorarrow")
                    .padding(.leading, 15)
                Text("Details")
                    .font(.system(size: 18, design: .rounded))
                    .bold()
                    
                Rectangle()
                    .fill(Color.onBackground)
                    .offset(x: 7.5)
                    .frame(height: 1.5)
                    .padding(.trailing, 25)
            }
            VStack  {
                EventDetailsBodyBuilder(title: "Course", image: "text.book.closed") {
                    Text(event.course.englishName)
                }
                EventDetailsBodyBuilder(title: "Teachers", image: "person.3.sequence") {
                    ForEach(event.teachers, id: \.self) { teacher in
                        Text("\(teacher.firstName) \(teacher.lastName)")
                            .font(.system(size: 17, design: .rounded))
                            .foregroundColor(.onSurface)
                    }
                }
                EventDetailsBodyBuilder(title: "Time", image: "clock") {
                    Text("\(event.from.ISOtoHoursAndMinutes()) - \(event.to.ISOtoHoursAndMinutes())")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(.onSurface)
                }
                EventDetailsBodyBuilder(title: "Locations", image: "mappin.and.ellipse") {
                    ForEach(event.locations, id: \.self) { location in
                        Text(location.id)
                            .font(.system(size: 17, design: .rounded))
                            .foregroundColor(.onSurface)
                    }
                }
                
                Spacer()
            }
            
        }
    }
}

