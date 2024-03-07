//
//  StringExtensions.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/9/23.
//

import Foundation
import SwiftUI

extension String {
    
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
    
    func isProvider() -> Bool {
        if self.isEmpty {
            return false
        }
        if self == "provider" {
            return true
        }  else {
            return false
        }
    }
    
    func isClient() -> Bool {
        if self.isEmpty {
            return false
        }
        if self == "client" {
            return true
        }  else {
            return false
        }
    }
    
    func getStatus() -> ServiceStatus {
        switch self {
        case "CONTACTED": return ServiceStatus.Hired
        case "PENDING": return ServiceStatus.Pending
        default: return ServiceStatus.Canceled
        }
    }
    
    func getStatusName() -> String {
        switch self {
        case "CONTACTED": return "Contratado"
        case "PENDING": return "Pendiente"
        default: return "Cancelado"
        }
    }
    
    func toUri() -> UriFile? {
        let uri = URL(string: self)
        if uri != nil {
            let imageAbsolutePath = uri!.absoluteString
            var name = ""
            if let index = imageAbsolutePath.lastIndex(of: "/") {
                name = String(imageAbsolutePath.suffix(from: index).dropFirst())
            }
            let url = self
            return UriFile(uri: uri!, fileName: name, url: url)
        } else {
            return nil
        }
    }
    
    func toUnit() -> String {
        switch self {
        case "Persona":
            return "person"
        case "Pieza":
            return "pz"
        case "Kg":
            return "kg"
        case "Evento":
            return "event"
        default: return ""
        }
    }
}

extension ServiceStatus {
    func getStatusColor() -> Color {
        switch self {
        case ServiceStatus.All: return Color(UIColor(hex: "#004FD5"))
        case ServiceStatus.Hired:  return Color(UIColor(hex: "#009E5D"))
        case ServiceStatus.Pending:  return Color(UIColor(hex: "#FFE800"))
        case ServiceStatus.Canceled:  return Color(UIColor(hex: "#FF0000"))
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

func openURLInBrowser(_ urlString: String) {
    if let url = URL(string: urlString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
