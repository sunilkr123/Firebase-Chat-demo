//
//  RecentChatTableViewCell.swift
//  FirebaseChat
//
//  Created by MacHD on 15/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapeAvtarImaeg(indexPath:IndexPath)
}


class RecentChatTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avtarImageView: UIImageView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var LastMessaeLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var CounterView: UIView!
    var tapGesture = UITapGestureRecognizer()
    var indexPath:IndexPath!
     var delegate:RecentChatTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(self.avatatarTap))
        tapGesture.numberOfTapsRequired = 1
        avtarImageView.isUserInteractionEnabled = true
        avtarImageView.addGestureRecognizer(tapGesture)
        CounterView.layer.cornerRadius = CounterView.frame.height/2
        CounterView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func GenerateCell(recentChat:NSDictionary,indexpath:IndexPath){
        self.indexPath = indexpath
        UserNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        let decryptedText = Encryption.decryptText(chatRoomId: recentChat[kCHATROOMID] as! String, encryptedMessage: recentChat[kLASTMESSAGE] as! String)
        LastMessaeLabel.text = decryptedText
        if let avatarIamge = recentChat[kAVATAR] as? String{
             imageFromData(pictureData: avatarIamge) { (avatarIamge) in
                if avatarIamge != nil{
                    self.avtarImageView.image = avatarIamge!.circleMasked
                }
            }
        }
        if recentChat[kCOUNTER] as! Int != 0{
            print("kCOUNTER kCOUNTER kCOUNTER",recentChat[kCOUNTER])
            let counter =  recentChat[kCOUNTER] as? String
              print("kCOUNTER kCOUNTER kCOUNTER",counter)
            counterLabel.text = "\(recentChat[kCOUNTER]!)"
        }else{
           counterLabel.isHidden = true
        }
        
        var date : Date!
        if let created = recentChat[kDATE]{
            if (created as? String)?.count != 14{
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
                
            }
        }else{
            date = Date()
        }
        self.DateLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatatarTap(){
    delegate?.didTapeAvtarImaeg(indexPath:indexPath!)
    }
    
    
}
