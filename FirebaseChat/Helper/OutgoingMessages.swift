//
//  OutgoingMessages.swift
//  iChat
//
//  Created by David Kababyan on 16/06/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation


class OutgoingMessage {
    
    let messageDictionary: NSMutableDictionary
    
    //MARK: Initializers
    
    //text message
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }

    //picture message
    init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //audio message
    init(message: String, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, audio, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kAUDIO as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //video message
    init(message: String, video: String, thumbNail: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        let picThumb = thumbNail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        messageDictionary = NSMutableDictionary(objects: [message, video, picThumb, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //loaction message
    init(message: String, latitude: Double, longitude: Double, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kLATITUDE as NSCopying, kLONGITUDE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: SendMessage
    func sendMessage(chatRoomID: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
     reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messageDictionary as! [String : Any])
        }
         updateRecents(chatRoomId: chatRoomID, lastMessage: messageDictionary[kMESSAGE] as! String)
         var pushText = ""
        if let last = messageDictionary[kLASTMESSAGE] as? String{
             pushText = "[\(messageDictionary[kLASTMESSAGE] as! String) message]"
        }else{
            pushText = messageDictionary[kMESSAGE] as! String
        }
        let decriptMessage = Encryption.decryptText(chatRoomId: chatRoomID, encryptedMessage: pushText)
        //
        print("message is \(pushText),,,, decriptded message is \(decriptMessage)")
        sendPushNotification(memberToPush: membersToPush, message: decriptMessage)
    }

    
    class func deleteMessage(withId: String, chatRoomId: String) {
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).document(withId).delete()
    }
    
    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {

        let readDate = dateFormatter().string(from: Date())
        
        let values = [kSTATUS : kREAD, kREADDATE : readDate]
        
        for userId in memberIds {
            
            reference(.Message).document(userId).collection(chatRoomId).document(withId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot  else { return }
                
                if snapshot.exists {
                    
                    reference(.Message).document(userId).collection(chatRoomId).document(withId).updateData(values)
                }
            }
        }
    }
}
