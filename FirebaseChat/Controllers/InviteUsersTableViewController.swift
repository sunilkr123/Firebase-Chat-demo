//
//  InviteUsersTableViewController.swift
//  iChat
//
//  Created by David Kababyan on 07/07/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class InviteUsersTableViewController: UITableViewController, UserTableViewCellDelegate {
   
    @IBOutlet weak var headerView: UIView!
    
    var allUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []

    var newMemberIds: [String] = []
    var currentMemberIds: [String] = []
    var group: NSDictionary!
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(filter: " ")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        tableView.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        currentMemberIds = group[kMEMBERS] as! [String]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.allUsersGroupped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionTitle = self.sectionTitleList[section]
        
        let users = self.allUsersGroupped[sectionTitle]
        
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGroupped[sectionTitle]
        
        cell.GenerateCellWith(fUser: users![indexPath.row], indexPath: indexPath, currentUser: FUser.currentUser()!)
        cell.delegate = self
        
        return cell
    }
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitleList[section]
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return self.sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        
        let users = self.allUsersGroupped[sectionTitle]
        
        let selectedUser = users![indexPath.row]
        
        if currentMemberIds.contains(selectedUser.objectId) {
            ProgressHUD.showError("Already in the group!")
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        
        
        //add/remove users
        let selected = newMemberIds.contains(selectedUser.objectId)
        
        if selected {
            //remove
            let objectIndex = newMemberIds.index(of: selectedUser.objectId)!
            newMemberIds.remove(at: objectIndex)
            
        } else {
            //add to array
            newMemberIds.append(selectedUser.objectId)
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = newMemberIds.count > 0
    }


    //MARK: LoadUsers
    
    func loadUsers(filter: String) {
        
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                
                
                self.splitDataIntoSection()
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
            
        }
        
    }
    
   //MARK: IBactions
    @IBAction func filtervaluechanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
              loadUsers(filter: "")
        case 1:
             loadUsers(filter: kCITY)
        case 2:
            loadUsers(filter: kCOUNTRY)
        default:
            return
        }
    }
    

 
    
   
    
    @objc func doneButtonPressed() {
        
        updateGroup(group: group)
    }
    
    //MARK: UsersTableViewCellDelegate
    func didTapeAvtarImaeg(indexPath: IndexPath) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        
        let users = self.allUsersGroupped[sectionTitle]
        
        profileVC.user = users![indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    //MARK: Helper functions
    
    func updateGroup(group: NSDictionary) {
        
        let tempMembers = currentMemberIds + newMemberIds
        let tempMembersToPush = group[kMEMBERSTOPUSH] as! [String] + newMemberIds
        
        let withValues = [kMEMBERS : tempMembers, kMEMBERSTOPUSH : tempMembersToPush]
        
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        
        createRecentsForNewMembers(groupId: group[kGROUPID] as! String, groupName: group[kNAME] as! String, membersToPush: tempMembersToPush, avatar: group[kAVATAR] as! String)
        
        updateExistingRicentWithNewValues(chatRoomId: group[kGROUPID] as! String, members: tempMembers, withValues: withValues)
        
        goToGroupChat(membersToPush: tempMembersToPush, members: tempMembers)
        
    }
    
    func goToGroupChat(membersToPush: [String], members: [String]) {
        
        let chatVC = ChatViewController()
        
        chatVC.titleName = group[kNAME] as! String
        chatVC.memberIds = members
        chatVC.membersToPush = membersToPush
        
        chatVC.chatRoomId = group[kGROUPID] as! String
        chatVC.isGroup = true
        chatVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    fileprivate func splitDataIntoSection() {
        
        var sectionTitle: String = ""
        
        for i in 0..<self.allUsers.count {
            
            let currentUser = self.allUsers[i]
            
            let firstChar = currentUser.firstname.first!
            
            let firstCarString = "\(firstChar)"
            
            
            if firstCarString != sectionTitle {
                
                sectionTitle = firstCarString
                
                self.allUsersGroupped[sectionTitle] = []
                
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
            }
            
            self.allUsersGroupped[firstCarString]?.append(currentUser)
            
        }
        
    }


}
