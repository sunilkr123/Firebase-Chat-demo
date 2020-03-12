//
//  NewGroupViewController.swift
//  iChat
//
//  Created by David Kababyan on 05/07/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker
import JSQMessagesViewController
import FirebaseFirestore

class NewGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupMemberCollectionViewCellDelegate, ImagePickerDelegate {
    

    @IBOutlet weak var editAvatarButtonOutlet: UIButton!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
       groupIconImageView.isUserInteractionEnabled = true
       groupIconImageView.addGestureRecognizer(iconTapGesture)
        
        updateParticipantsLabel()
    }
    
    
    //MARK: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GroupMemberCollectionViewCell
        
        cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    //MARK: IBActions
     @objc func createButtonPressed(_ sender: Any) {
         if groupSubjectTextField.text != "" {
            memberIds.append(FUser.currentId())
            let avatarData = UIImage(named: "groupIcon")!.jpegData(compressionQuality: 0.7)!
            var avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            if groupIcon != nil {
               let avatarData = groupIcon!.jpegData(compressionQuality: 0.4)!
                avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            let groupId = UUID().uuidString
            let group = Group(groupId: groupId, subject: groupSubjectTextField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar)
             group.saveGroup()
            let chatroomID = group.groupDictionary[kGROUPID] as! String
            var outgoingMessage: OutgoingMessage?
            let currentUser = FUser.currentUser()!
            let ecryptedText = Encryption.encryptText(chatRoomId: chatroomID, message: "Group is created by \(FUser.currentUser()!.firstname)")
            outgoingMessage = OutgoingMessage(message: ecryptedText, senderId: currentUser.objectId, senderName: currentUser.firstname, date: Date(), status: kDELIVERED, type: kTEXT)
            outgoingMessage!.sendMessage(chatRoomID: chatroomID, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: memberIds)
            startGroupChat(group: group)
            let chatVC = ChatViewController()
            chatVC.titleName = group.groupDictionary[kNAME] as? String
            chatVC.memberIds = group.groupDictionary[kMEMBERS] as! [String]
            chatVC.membersToPush = group.groupDictionary[kMEMBERS] as! [String]
            chatVC.chatRoomId = groupId
            chatVC.isGroup = true
            chatVC.hidesBottomBarWhenPushed = true
             chatVC.finishSendingMessage()
            self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
            ProgressHUD.showError("Subject is required!")
        }
    }
    
    
    @IBAction func groupIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editIconButtonPressed(_ sender: Any) {
        showIconOptions()
    }
  
    //MARK: GroupMemberCollectionViewDelegate
     func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        collectionView.reloadData()
        updateParticipantsLabel()
    }

    //MARK: HelperFunctions
    
    func showIconOptions() {
        let optionMenu = UIAlertController(title: "Choose group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoActio = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageLimit = 1
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert)in}
        if groupIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in
                self.groupIcon = nil
                self.groupIconImageView.image = UIImage(named: "cameraIcon")
                self.editAvatarButtonOutlet.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoActio)
        optionMenu.addAction(cancelAction)
        
        if ( UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = editAvatarButtonOutlet
                currentPopoverpresentioncontroller.sourceRect = editAvatarButtonOutlet.bounds
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    func updateParticipantsLabel() {
        participantsLabel.text = "PARTICIPANTS: \(allMembers.count)"
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }

    //MARK: ImagePickerControllerDelegate
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.groupIcon = images.first!
            self.groupIconImageView.image = self.groupIcon!.circleMasked
            self.editAvatarButtonOutlet.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }


    
}
