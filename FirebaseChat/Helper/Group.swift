//
//  Group.swift
//  iChat
//
//  Created by David Kababyan on 07/07/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Group {
    
    let groupDictionary: NSMutableDictionary
    
    init(groupId: String, subject: String, ownerId: String, members: [String], avatar: String) {
        
        groupDictionary = NSMutableDictionary(objects: [groupId, subject, ownerId, members, members, avatar], forKeys: [kGROUPID as NSCopying, kNAME as NSCopying, kOWNERID as NSCopying, kMEMBERS as NSCopying, kMEMBERSTOPUSH as NSCopying, kAVATAR as NSCopying])
    }
    
    func saveGroup() {
        
        let date = dateFormatter().string(from: Date())
        groupDictionary[kDATE] = date
        reference(.Group).document(groupDictionary[kGROUPID] as! String).setData(groupDictionary as! [String:Any])
    }
    
    class func updateGroup(groupId: String, withValues: [String:Any]) {
        reference(.Group).document(groupId).updateData(withValues)
    }
    
    
}
