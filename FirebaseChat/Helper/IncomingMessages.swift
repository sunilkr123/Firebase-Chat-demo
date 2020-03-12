//
//  IncomingMessages.swift
//  iChat
//
//  Created by David Kababyan on 17/06/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    
    //MARK: CreateMessage
//
  func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {

        var message: JSQMessage?

        let type = messageDictionary[kTYPE] as! String

        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
          message = createVideoMessage(messageDictionary: messageDictionary)
       case kAUDIO:
         message = createAudioMessage(messageDictionary: messageDictionary)
       case kLOCATION:
          message = createLocationMessage(messageDictionary: messageDictionary)
        default:
            print("Unknown message type")
        }
    
    
        if message != nil {
           return message
        }

        return nil
    }

    
    //MARK: Create Message types
//
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {

        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String

        var date: Date!

        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
     let decryptedText = Encryption.decryptText(chatRoomId: chatRoomId, encryptedMessage: messageDictionary[kMESSAGE] as! String)
        print("message is ", messageDictionary[kMESSAGE] as! String)
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: decryptedText)
    }

    //for image
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {

        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String

        var date: Date!

        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }

        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        //doenload image
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            
            if image != nil {
                mediaItem?.image = image!
                self.collectionView.reloadData()
            }
        }

        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }

    //video
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        
        let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
        
        
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        
        
      //  doenload video
        
        downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in

            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))

            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url

            imageFromData(pictureData: messageDictionary[kPICTURE] as! String, withBlock: { (image) in

                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                }
            })

            self.collectionView.reloadData()
        }
      return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }

    
    //Audio
    func createAudioMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        
        
        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        let audioMessage = JSQMessage(senderId: userId!, displayName: name!, media: audioItem)
        
        
        //doenload audio
        downloadAudio(audioUrl: messageDictionary[kAUDIO] as! String) { (fileName) in

            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))

            let audioData = try? Data(contentsOf: url as URL)
            audioItem.audioData = audioData

            self.collectionView.reloadData()
        }
//
        
        return audioMessage!
    }
    
    
    func createLocationMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        
        let latitude = messageDictionary[kLATITUDE] as? Double
        let longitude = messageDictionary[kLONGITUDE] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }


    
    //MARK: Helper
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
    
        return senderId == FUser.currentId()
    }


}
