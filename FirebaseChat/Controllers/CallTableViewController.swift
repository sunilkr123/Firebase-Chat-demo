//
//  CallTableViewController.swift
//  iChat
//
//  Created by David Kababyan on 15/07/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseFirestore

class CallTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    
    var allCalls: [CallClass] = []
    var filteredCalls: [CallClass] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let searchController = UISearchController(searchResultsController: nil)
    var callListener: ListenerRegistration!
    var user:CallClass?
    
    override func viewWillAppear(_ animated: Bool) {
        loadCalls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBadges(controller: self.tabBarController!)

        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }

    //MARK: TableViewDataSource

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCalls.count
        }
        return allCalls.count
       
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CallTableViewCell
        var call: CallClass!
        if searchController.isActive && searchController.searchBar.text != "" {
            call = filteredCalls[indexPath.row]
        } else {
            call = allCalls[indexPath.row]
        }
       cell.generateCellWith(call: call)
        return cell
    }
    
    
    //MARK: TableViewDelegate
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var tempCall: CallClass!
            
            if searchController.isActive && searchController.searchBar.text != "" {
                tempCall = filteredCalls[indexPath.row]
                filteredCalls.remove(at: indexPath.row)
            } else {
                tempCall = allCalls[indexPath.row]
                allCalls.remove(at: indexPath.row)
            }
            
            tempCall.deleteCall()
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         //  user = allCalls[indexPath.row]
//          callUser()
//        let currentUser = FUser.currentUser()!
//        let call = CallClass(_callerId: currentUser.objectId, _withUserId: user!.objectId, _callerFullName: currentUser.fullname, _withUserFullName: user!.withUserFullName)
//        call.saveCallInBackground()
    }
    
    
   
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
    
    
    
    //MARK: LoadCalls
    
    func loadCalls() {
        
        callListener = reference(.Call).document(FUser.currentId()).collection(FUser.currentId()).order(by: kDATE, descending: true).limit(to: 20).addSnapshotListener({ (snapshot, error) in
            
            self.allCalls = []
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                let sortedDictionary = dictionaryFromSnapshots(snapshots: snapshot.documents)
                
                for callDictionary in sortedDictionary {
                    let call = CallClass(_dictionary: callDictionary)
                    self.allCalls.append(call)
                }
                
            }
          
            self.tableView.reloadData()
              self.AnimateableView()
        })
    }

    
    //MARK: Search controller
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredCalls = allCalls.filter({ (call) -> Bool in
            
            var callerName: String!
            
            if call.callerId == FUser.currentId() {
                callerName = call.withUserFullName
            } else {
                callerName = call.callerFullName
            }
            
            return (callerName).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
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
