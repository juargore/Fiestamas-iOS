//
//  CustomCalendarView.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 12/19/23.
//

import Foundation
import SwiftUI

struct CircleEventPerDay: Hashable {
    let time: Date
    let color: Color
}

struct CustomCalendarView: View {
    
    var circlesPerDay: [CircleEventPerDay]
    
    @State private var currentDate = Date()

    var body: some View {
        VStack {
            
            // < diciembre 2023 >
            HStack {
                Button(action: {
                    self.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate) ?? Date()
                }) {
                    Image(systemName: "chevron.left")
                }
                .padding(.trailing, 20)

                Text(getFormattedMonthYear(date: currentDate).capitalizeFirstLetter())
                    .font(.title3)

                Button(action: {
                    self.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate) ?? Date()
                }) {
                    Image(systemName: "chevron.right")
                }
                .padding(.leading, 20)
            }
            .padding()

            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: currentDate)!.count
            let columns = Array(repeating: GridItem(), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    VStack {
                        //let _ = debugPrint("Day: \(day) in ", self.currentDate)
                        Text("\(day)")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack {
                            ForEach(circlesData(
                                for: day,
                                currentDate: self.currentDate,
                                circles: circlesPerDay), id: \.self
                            ) { circle in
                                //let _ = debugPrint("Date: ", circle.time)
                                
                                Circle()
                                    .foregroundColor(circle.color)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .frame(height: 40)
                }
            }
            .padding()
        }
    }
    
    func circlesData(for day: Int, currentDate: Date, circles: [CircleEventPerDay]) -> [CircleEventPerDay] {
        let calendar = Calendar.current
        let calendarYear = calendar.component(.year, from: currentDate)
        let calendarMonth = calendar.component(.month, from: currentDate)
        
        let filteredCircles = circles.filter { circle in
            let circleYear = calendar.component(.year, from: circle.time)
            let circleMonth = calendar.component(.month, from: circle.time)
            let circleDay = calendar.component(.day, from: circle.time)
            
            return circleYear == calendarYear && circleMonth == calendarMonth && circleDay == day - 1
        }
        
        return filteredCircles
    }

    func getFormattedMonthYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
}
