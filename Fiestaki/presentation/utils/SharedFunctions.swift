//
//  SharedFunctions.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/9/23.
//

import Foundation
import SwiftUI

extension String {
    func getRole() -> Role {
        if self.isProvider() {
            return Role.Provider
        } else if self.isClient() {
            return Role.Client
        } else {
            return Role.Unauthenticated
        }
    }
}

func convertNotificationDbToNotification(
    isProvider: Bool,
    serviceEvent: MyPartyService?,
    notification: NotificationDb?
) -> Notification {
    var status = NotificationStatus.Unread
    if notification?.read == true {
        status = NotificationStatus.Read
    }
    let messageType: MessageType = fromString(notification?.type)
    let date = convertStringToDate(notification?.timestamp)
    let dateHour = convertDateToDateAndHour(date: date)
    
    return Notification(
        id: notification?.id ?? "",
        status: status,
        icon: serviceEvent?.image ?? "",
        eventName: serviceEvent?.service_category_name ?? "",
        eventType: serviceEvent?.event_data?.name_event_type ?? "",
        festejadosName: serviceEvent?.event_data?.name ?? "",
        serviceName: serviceEvent?.name ?? "",
        message: notification?.content ?? "",
        clientName: notification?.name_sender ?? "",
        providerName: serviceEvent?.provider_contact_name ?? "",
        idReceiver: notification?.id_receiver ?? "",
        idSender: notification?.id_sender ?? "",
        date: "\(dateHour.formattedDate) \(dateHour.formattedTime)",
        clientEventId: notification?.id_client_event ?? "",
        receiverId: notification?.id_receiver ?? "",
        senderId: notification?.id_sender ?? "",
        receiverPhoto: notification?.photo_receiver ?? "",
        senderPhoto: notification?.photo_sender ?? "",
        serviceId: notification?.id_service ?? "",
        serviceEventId: notification?.id_service_event ?? "",
        serviceEvent: serviceEvent,
        isApproved: notification?.is_approved ?? false,
        type: messageType
    )
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegex = try! NSRegularExpression(pattern: "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: [])
    let range = NSRange(location: 0, length: email.utf16.count)
    return emailRegex.firstMatch(in: email, options: [], range: range) != nil
}

func isValidPassword(_ password: String) -> Bool {
    let pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#\\$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$"
    
    if let regex = try? NSRegularExpression(pattern: pattern) {
        let range = NSRange(location: 0, length: password.utf16.count)
        return regex.firstMatch(in: password, options: [], range: range) != nil
    }
    
    return false
}

func getUriFromImage(_ image: Image, width: CGFloat, height: CGFloat) -> URL? {
    // convert image from SwiftUI to UIImage
    guard let uiImage = image.asUIImage(width, height) else {
        debugPrint("AQUI: return nil 1")
        return nil
    }
    
    // save image in temp files
    guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else { //0.8
        debugPrint("AQUI: return nil 2")
        return nil
    }
    
    do {
        // create temp URL to store image
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirectoryURL.appendingPathComponent("tempImage\(getCurrentDateTimeInSeconds()).jpg")
        
        // save image in system temp file
        try imageData.write(to: fileURL)
        
        return fileURL
    } catch {
        print("Error al guardar la imagen: \(error.localizedDescription)")
        return nil
    }
}

func getCurrentDateTimeInSeconds() -> String {
    let currentDate = Date()
    let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
    return String(currentTimeStamp)
}

extension Image {
    /*func asUIImage() -> UIImage? {
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)) // image size
        let hostingController = UIHostingController(rootView: self)
        uiView.addSubview(hostingController.view)
        
        let renderer = UIGraphicsImageRenderer(size: uiView.bounds.size)
        let uiImage = renderer.image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
        
        return uiImage
    }*/
    
    /*func asUIImage(_ nWidth: CGFloat, _ nHeight: CGFloat) -> UIImage? {
        
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: nWidth, height: nHeight)) // image size
        let hostingController = UIHostingController(rootView: self)
        uiView.addSubview(hostingController.view)
        
        let newWidth: CGFloat = nWidth / 5
        let newHeight: CGFloat = nHeight / 5

        // Cambiar el tamaño de la vista usando CGRect
        uiView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        let renderer = UIGraphicsImageRenderer(size: uiView.bounds.size)
        let uiImage = renderer.image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
        
        return uiImage
    }*/
    
    func asUIImage(_ width: CGFloat, _ height: CGFloat) -> UIImage? {
            // Crear una vista con el tamaño deseado
            let uiView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            
            // Crear un controlador de host (HostingController) para la imagen
            let hostingController = UIHostingController(rootView: self)
            hostingController.view.frame = uiView.bounds
            
            // Agregar la vista del controlador de host a la vista creada
            uiView.addSubview(hostingController.view)
            
            // Redimensionar la vista a un tercio del tamaño original
            let newWidth: CGFloat = width / 3
            let newHeight: CGFloat = height / 3
            uiView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            
            // Renderizar la vista en un objeto UIImage
            let renderer = UIGraphicsImageRenderer(size: uiView.bounds.size)
            let uiImage = renderer.image { _ in
                uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
            }
            
            return uiImage
        }
}

extension View {
    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {
            
            placeholder(when: shouldShow, alignment: alignment) {
                Text(text)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 14)
            }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
