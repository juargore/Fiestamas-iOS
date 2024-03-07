//
//  DateExtensions.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/9/23.
//

import Foundation

func convertStringToDate(_ dateString: String?) -> Date {
    if dateString == nil { return Date.now }
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.timeZone = TimeZone(identifier: "UTC")
    return isoFormatter.date(from: dateString!) ?? Date.now
}

func convertStringToDateUTC(_ dateString: String?) -> Date {
    guard let dateString = dateString, !dateString.isEmpty else {
        return Date()
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX" // Set format as 'X' to convert correctly the 'Z'
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    if let convertedDate = dateFormatter.date(from: dateString) {
        return convertedDate
    } else {
        debugPrint("AQUI: Error en la conversión.")
        return Date()
    }
}

func daysUntilDate(_ targetDate: Date?) -> Int {
    if targetDate == nil { return 0 }
    let calendar = Calendar.current
    let currentDate = Date()
    if let difference = calendar.dateComponents([.day], from: currentDate, to: targetDate!).day {
        return max(0, difference)
    } else {
        return 0
    }
}

typealias DatePair = (formattedDate: String, formattedTime: String)

func convertDateToDateAndHour(date: Date?) -> DatePair {
    guard let date = date else {
        return ("", "")
    }

    let timeZone = TimeZone(identifier: "UTC")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    dateFormatter.locale = Locale.current
    dateFormatter.timeZone = timeZone

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm 'hrs'"
    timeFormatter.locale = Locale.current
    timeFormatter.timeZone = timeZone

    let formattedDate = dateFormatter.string(from: date)
    let formattedTime = timeFormatter.string(from: date)

    return (formattedDate, formattedTime)
}

func convertDateToDateAndWeekDay(date: Date?) -> (String, String) {
    guard let date = date else {
        return ("", "")
    }

    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "dd-MM-yy"

    let dayOfWeekFormat = DateFormatter()
    dayOfWeekFormat.dateFormat = "EEEE"
    dayOfWeekFormat.locale = Locale(identifier: "es_ES")

    let dateString = dateFormat.string(from: date)
    let weekDayString = dayOfWeekFormat.string(from: date)

    return (dateString, weekDayString)
}

func convertDateUTC(date: Date?) -> (String, String) {
    guard let date = date else {
        return ("", "")
    }

    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "dd-MM-yy"
    dateFormat.timeZone = TimeZone(identifier: "UTC")

    let dayOfWeekFormat = DateFormatter()
    dayOfWeekFormat.dateFormat = "EEEE"
    dayOfWeekFormat.locale = Locale(identifier: "es_ES")
    dayOfWeekFormat.timeZone = TimeZone(identifier: "UTC")

    let dateString = dateFormat.string(from: date)
    let weekDayString = dayOfWeekFormat.string(from: date)

    return (dateString, weekDayString)
}

func stringToISO8601(inputDate: String) -> String {
    let inputFormat = DateFormatter()
    inputFormat.dateFormat = "yyyy-MM-dd H:mm"
    
    guard let dateTime = inputFormat.date(from: inputDate) else {
        return Date.now.description
    }
    
    let outputFormat = DateFormatter()
    outputFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    //outputFormat.timeZone = TimeZone(abbreviation: "UTC")
    
    return outputFormat.string(from: dateTime)
}
