//
//  ChatsViewController.swift
//  FirebaseChat
//
//  Created by MacHD on 11/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import ABLoaderView
import FirebaseFirestore
import IDMPhotoBrowser
class ChatsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,RecentChatTableViewCellDelegate{
    
    @IBOutlet weak var tableview: UITableView!
   let searchController = UISearchController(searchResultsController: nil)
    var recentChats = [NSDictionary]()
    var filteredChats = [NSDictionary]()
    var recentLitner: ListenerRegistration!
    var user:FUser?
      var isloaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewHeader()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableview.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
         loadRecentChats()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentLitner.remove()
    }
    
    @IBAction func creatNewChatbtn(_ sender:UIBarButtonItem){
//        let chatmainview = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTableViewController") as! UserTableViewController
//        self.navigationController?.pushViewController(chatmainview, animated: true)
        let chatmainview = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactsTableViewController") as! ContactsTableViewController
        self.navigationController?.pushViewController(chatmainview, animated: true)
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count of the recnt chat array is",recentChats.count)
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        } else {
            return recentChats.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentChatTableViewCell", for: indexPath) as! RecentChatTableViewCell
        cell.delegate = self
        var recent: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
//        if isloaded == false{
//            ABLoader().startSmartShining(cell.contentView)
//        }else{
//            ABLoader().stopSmartShining(cell.contentView)
//        }
        cell.GenerateCell(recentChat: recent, indexpath: indexPath)
        cell.selectionStyle = .none
         return cell
    }
  
    //MARK: TableViewDelegate functions
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempRecent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            tempRecent = filteredChats[indexPath.row]
        } else {
            tempRecent = recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
            
            deleteRecentChat(recentChatDictionary: tempRecent)
            
            self.tableview.reloadData()
        }
        
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            
           self.updatePushMembers(recent: tempRecent, mute: mute)
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        return [deleteAction, muteAction]
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        
        restartRecentChat(recent: recent)
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        chatVC.isGroup = (recent[kTYPE] as! String) == kGROUP
         navigationController?.pushViewController(chatVC, animated: true)
    }


    func updatePushMembers(recent: NSDictionary, mute: Bool) {
        
        var membersToPush = recent[kMEMBERSTOPUSH] as! [String]
        
        if mute {
            let index = membersToPush.index(of: FUser.currentId())!
            membersToPush.remove(at: index)
        } else {
            membersToPush.append(FUser.currentId())
        }
        
        updateExistingRicentWithNewValues(chatRoomId: recent[kCHATROOMID] as! String, members: recent[kMEMBERS] as! [String], withValues: [kMEMBERSTOPUSH : membersToPush])
        
    }
    
    //MARK: Search controller functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
           return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableview.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    //MARK: RecentChatsCell delegate
    
    func didTapeAvtarImaeg(indexPath: IndexPath) {
        
        var recentChat: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recentChat = filteredChats[indexPath.row]
        } else {
            recentChat = recentChats[indexPath.row]
        }
        if let avatarIamge = recentChat[kAVATAR] as? String{
            imageFromData(pictureData: avatarIamge) { (avatarIamge) in
                if avatarIamge != nil{
                    let photos = IDMPhoto.photos(withImages: [avatarIamge])
                    if photos != nil{
                        let browser = IDMPhotoBrowser(photos: photos)
                        self.present(browser!, animated: true, completion: nil)
                    }
                }
            }
        }
             print("tapped on image")
//        if recentChat[kTYPE] as! String == kPRIVATE {
//            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
//                guard let snapshot = snapshot else { return }
//                if snapshot.exists {
//                    let userDictionary = snapshot.data() as! NSDictionary
//                    let tempUser = FUser(_dictionary: userDictionary)
//                    self.showUserProfile(user: tempUser)
//                }
//
//            }
//        }
        
    }
    
    func showUserProfile(user: FUser) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
       profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    //MARK: LoadRecentChats
    
    func loadRecentChats() {
            recentLitner = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            if !snapshot.isEmpty {
               let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                          self.recentChats.append(recent)
                    }
                    reference(.Recent).whereField(kCHATROOMID, isEqualTo: recent[kCHATROOMID] as! String).getDocuments(completion: { (snapshot, error) in
                    })
                }
              /// self.isloaded = true
              self.tableview.reloadData()
               // self.AnimateableView()
            }
            
        })
        
    }

    //MARK: Custom tableViewHeader
    
    func setTableViewHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableview.frame.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableview.frame.width, height: 35))
        let groupButton = UIButton(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width-20, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        groupButton.contentHorizontalAlignment = .right
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableview.frame.width+200, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        tableview.tableHeaderView = headerView
    }
    @objc func groupButtonPressed() {
      selectUserForChat(isGroup: true)
    }
    func selectUserForChat(isGroup: Bool) {
       let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactsTableViewController") as! ContactsTableViewController
         contactsVC.isGroup = isGroup
         self.navigationController?.pushViewController(contactsVC, animated: true)
    }
    func AnimateableView(){
        tableview.reloadData()
        let cells = tableview.visibleCells
        let tableviewheight = tableview.bounds.size.height
        
        for cell in cells{
            cell.transform = CGAffineTransform(translationX: 0, y: tableviewheight)
        }
        var delayCounter = 0
        for cell in cells{
            UIView.animate(withDuration: 1, delay: Double(delayCounter)*0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
                delayCounter += 1
            }, completion: nil)
        }
    }
}
