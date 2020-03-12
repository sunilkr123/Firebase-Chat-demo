//
//  UserTableViewCell.swift
//  FirebaseChat
//
//  Created by MacHD on 11/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
func didTapeAvtarImaeg(indexPath:IndexPath)
}



class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var Username: UILabel!
    
    @IBOutlet weak var blockedUserStatusLabel: UILabel!
    
    
    var indexPath:IndexPath?
    let tapgestureRecognizer = UITapGestureRecognizer()
    var delegate:UserTableViewCellDelegate?
    
     override func awakeFromNib() {
        super.awakeFromNib()
        tapgestureRecognizer.addTarget(self, action: #selector(self.avatatarTap))
        AvatarImageView.isUserInteractionEnabled = true
        AvatarImageView.addGestureRecognizer(tapgestureRecognizer)
    }

    
    func GenerateCellWith(fUser:FUser,indexPath: IndexPath,currentUser:FUser
        )  {
        self.indexPath = indexPath
        self.Username.text = fUser.fullname
         if (currentUser.blockedUsers.contains(fUser.objectId)){
            blockedUserStatusLabel.isHidden = false
            AvatarImageView.image = UIImage(named: "Blocked User")
        }else{
            blockedUserStatusLabel.isHidden = true
            if fUser.avatar != nil{
                imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                    if avatarImage != nil{
                        self.AvatarImageView.image = avatarImage?.circleMasked
                    }
                }
            }
        //AvatarImageView.image = UIImage(named: "Blocked User")
        }
    }
    
    
    
 @objc  func avatatarTap() {
    delegate?.didTapeAvtarImaeg(indexPath:indexPath!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   }

}
