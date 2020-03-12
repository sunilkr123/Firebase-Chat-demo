//
//  UserTableViewController.swift
//  FirebaseChat
//
//  Created by MacHD on 11/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD
class UserTableViewController: UITableViewController,UISearchBarDelegate,UISearchResultsUpdating,UISearchControllerDelegate,UserTableViewCellDelegate{
   
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var filterSegmentControler: UISegmentedControl!
    var allUser = [FUser]()
    var fileteredarr = [FUser]()
    var allUserGrouped = NSDictionary() as! [String:[FUser]]
   var sectionTitleList : [String] = []
    var searchController = UISearchController(searchResultsController: nil)
      var filteredUsers: [FUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Users List"
        tableView.tableFooterView = UIView()
       
        // to add the search controller bar
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
           loadUsers(filter: "")
       
    }

    // MARK: - Table view data source

   
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return allUserGrouped.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count
            
        } else {
            
            //find section Title
            let sectionTitle = self.sectionTitleList[section]
            
            //user for given title
            let users = self.allUserGrouped[sectionTitle]
            
            return users!.count
        }
        
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUserGrouped[sectionTitle]
            
            user = users![indexPath.row]
        }
        cell.GenerateCellWith(fUser: user, indexPath: indexPath, currentUser: FUser.currentUser()!)
        
        cell.delegate = self
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUserGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        print("\(user) \(FUser.currentUser())")
      //  startPrivateChat(user1: FUser.currentUser()!, user2: user)
        if !checkBlockedStatus(withUser: user) {
            
            let chatVC = ChatViewController()
            chatVC.titleName = user.firstname
            chatVC.membersToPush = [FUser.currentId(), user.objectId]
            chatVC.memberIds = [FUser.currentId(), user.objectId]
            chatVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user)
            
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
            
            
        } else {
            ProgressHUD.showError("This user is not available for chat!")
        }
        
    }
    
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return sectionTitleList[section]
        }
    }
    
   override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
       return index
    }
    
    
    
    
    
    @IBAction func filtersegmentsValueChanged(_ sender:AnyObject) {
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
            
            self.allUser = []
            self.sectionTitleList = []
            self.allUserGrouped = [:]
            
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
                    print("snapshot snapshot snapshot",userDictionary)
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId() {
                        self.allUser.append(fUser)
                        print("count of the all users array",  self.allUser.count)
                    }
                }
                
               //  self.splitDataIntoSection()
             var sectionTitle: String = ""
                for i in 0..<self.allUser.count {
                    let currentUser = self.allUser[i]
                    let firstChar = currentUser.firstname.first!
                    let firstCarString = "\(firstChar)"
                    print("first character of the user is",firstCarString)
                    if firstCarString != sectionTitle {
                       sectionTitle = firstCarString
                       print("sectionTitle sectionTitle \(sectionTitle)")
                       self.sectionTitleList.append(sectionTitle)
                       self.allUserGrouped[sectionTitle] = []
                        
//                        if !sectionTitle.contains(sectionTitle) {
//                               print("sectionTitle sectionTitle 1111\(sectionTitle)")
//                            self.sectionTitleList.append(sectionTitle)
//                           print("numbr of tite is \(sectionTitle)")
//                        }
                        
                        
                    }
                    
                    self.allUserGrouped[firstCarString]?.append(currentUser)
                }
                self.tableView.reloadData()
                self.AnimateableView()
            }
          
            self.tableView.reloadData()
            self.AnimateableView()
            ProgressHUD.dismiss()
            
        }
        
    }
    
    
//MARK: Helper functions
//    fileprivate func splitDataIntoSection() {
//
//        var sectionTitle: String = ""
//        for i in 0..<self.allUser.count {
//            let currentUser = self.allUser[i]
//            let firstChar = currentUser.firstname.first!
//            let firstCarString = "\(firstChar)"
//            if firstCarString != sectionTitle {
//                sectionTitle = firstCarString
//                self.allUserGrouped[sectionTitle] = []
//                if !sectionTitle.contains(sectionTitle) {
//                    self.sectionTitleList.append(sectionTitle)
//                    print("SECTION TITLE IS",sectionTitle.count)
//                }
//            }
//            self.allUserGrouped[firstCarString]?.append(currentUser)
//         }
//
//    }
    
    

    //MARK: Search controller functions
    func filterContentForSearchText(searchText: String, scope: String = "All") {//All
        print("count of the all user",allUser.count)
        fileteredarr = allUser.filter({ (Fuser) -> Bool in
         print("searchText,searchText",searchText)
         print("boll Vool Bool\(Fuser.firstname.lowercased().contains(searchText.lowercased()))")
        return Fuser.firstname.uppercased().contains(searchText.uppercased())
        })
        
//        fileteredarr = allUser.filter({ (user) -> Bool in
//            print("searchText,searchText",searchText)
//            print("boll Vool Bool\(user.firstname.lowercased().contains(searchText.lowercased()))")
//            return user.firstname.lowercased().contains(searchText.lowercased())
//        })
         print("filteredUsers filteredUsers",filteredUsers.count)
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    //MARK: UserTableViewCellDelegate
    func didTapeAvtarImaeg(indexPath: IndexPath){
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        var user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUserGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //to animate the cell of the tableview
    func AnimateableView(){
        tableView.reloadData()
        let cells = tableView.visibleCells
        let tableviewheight = tableView.bounds.size.height
        
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
