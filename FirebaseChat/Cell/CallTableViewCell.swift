//
//  CallTableViewCell.swift
//  iChat
//
//  Created by David Kababyan on 15/07/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCellWith(call: CallClass) {
        
        dateLabel.text = formatCallTime(date: call.callDate)
        
        statusLabel.text = ""
        
        if call.callerId == FUser.currentId() {
            
            statusLabel.text = "Outgoing"
            fullNameLabel.text = call.withUserFullName
            
//            avatarImageView.image = UIImage(named: "Outgoin")
            
        } else {
            statusLabel.text = "Incoming"
            fullNameLabel.text = call.callerFullName
//            avatarImageView.image = UIImage(named: "Incoming")

        }
        
    }
    
    

}
