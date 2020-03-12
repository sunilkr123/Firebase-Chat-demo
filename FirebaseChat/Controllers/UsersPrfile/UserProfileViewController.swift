//
//  UserProfileViewController.swift
//  FirebaseChat
//
//  Created by MacHD on 14/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import ProgressHUD
class UserProfileViewController: UITableViewController {

    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var FullNameLabel: UILabel!
    @IBOutlet weak var MobileNumberLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var MessageButton: UIButton!
    @IBOutlet weak var BlockUser: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user:FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            SetUpUI()
           tableView.tableFooterView = UIView()
    }
    
    
    @IBAction func CallButtton(_ sender: Any) {
         callUser()
        let currentUser = FUser.currentUser()!
        let call = CallClass(_callerId: currentUser.objectId, _withUserId: user!.objectId, _callerFullName: currentUser.fullname, _withUserFullName: user!.fullname)
        call.saveCallInBackground()
    }
    
    
    @IBAction func Messagebutton(_ sender: Any) {
        if !checkBlockedStatus(withUser: user!) {
            let chatVC = ChatViewController()
            chatVC.titleName = user!.firstname
            chatVC.membersToPush = [FUser.currentId(), user!.objectId]
            chatVC.memberIds = [FUser.currentId(), user!.objectId]
            chatVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
          } else {
            ProgressHUD.showError("This user is not available for chat!. for chat you need to unblock this user")
        }
    }
    
    @IBAction func Blockbutton(_ sender: Any) {
        
        var currentBlockID = FUser.currentUser()!.blockedUsers
        if (currentBlockID.contains(user!.objectId)){
            currentBlockID.remove(at:currentBlockID.index(of: user!.objectId)!)
               print("block tapped")
        }else{
            currentBlockID.append(user!.objectId)
        }
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:currentBlockID]) { (error) in
            if error != nil{
                print("somethng went wrong\(error?.localizedDescription)")
                return
            }
             print("block tapped")
            self.BlockUserStatus()
        }
        print("block tapped")
    }
    
    

// MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
  
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 30
        }
    }
   
    //Ui Setup
    func SetUpUI() {
        self.title = ""
        FullNameLabel.text = user?.fullname
        MobileNumberLabel.text = user?.phoneNumber
        BlockUserStatus()
        imageFromData(pictureData: user!.avatar) { (Avatar) in
            if Avatar != nil{
            self.AvatarImageView.image = Avatar?.circleMasked
            }
        }
    }
    
    func BlockUserStatus(){
        if user?.objectId != FUser.currentId(){
            callButton.isHidden = false
             MessageButton.isHidden = false
            BlockUser.isHidden = false
        }else{
            callButton.isHidden = true
            MessageButton.isHidden = true
            BlockUser.isHidden = true
        }
         print("BlockUserStatus block tapped")
        
        if (FUser.currentUser()?.blockedUsers.contains(user!.objectId))!{
            BlockUser.setTitle("Unblock User", for: UIControl.State.normal)
        }else{
            BlockUser.setTitle("Bock User", for: UIControl.State.normal)
        }
        
    }
    
    
//   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//        return cell
//    }
   
    //MARK: CallUser
    
    func callClient() -> SINCallClient {
        return appDelegate._client.call()
    }
    
    
   
    
    func callUser() {
        
        let userToCall = user!.objectId
        let call = callClient().callUser(withId: userToCall)
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        callVC._call = call
        self.present(callVC, animated: true, completion: nil)
    }

}
