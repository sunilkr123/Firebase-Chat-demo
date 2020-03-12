//
//  PasswordChangeTableViewController.swift
//  FirebaseChat
//
//  Created by Sunil Kumar on 29/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import ProgressHUD
import MBProgressHUD
class PasswordChangeTableViewController: UITableViewController {

    @IBOutlet weak var newPasswordtextField: UITextField!
    @IBOutlet weak var confirmPasswordtextField: UITextField!
    @IBOutlet weak var oldPasswordtextField: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    //MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
        }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @IBAction func savebtn(_ sender: UIButton) {
        
        if oldPasswordtextField.text != ""{
            if newPasswordtextField.text! != ""{
                if confirmPasswordtextField.text! != ""{
                    if newPasswordtextField.text! == confirmPasswordtextField.text{
                          ProgressHUD.show("Saving...")
                        changePassword(email: FUser.currentUser()!.email, currentPassword: oldPasswordtextField.text!, newPassword: newPasswordtextField.text!) { (error) in
                            if error != nil{
                                print("Something went wrong!!")
                            }else{
                              
                                self.oldPasswordtextField.text = ""
                                self.newPasswordtextField.text = ""
                                self.confirmPasswordtextField.text = ""
                                ProgressHUD.showSuccess("Your password is changed successfully!")
                            }
                        }
                    }else{
                       ProgressHUD.showError("New and Confirm password is not equal")
                    }
                }else{
                   ProgressHUD.showError("Confirm password cannot be blank!")
                }
            }else{
               ProgressHUD.showError("New password cannot be blank!")
            }
           }else{
          ProgressHUD.showError("Old password cannot be blank!")
        }
        
    }
    
    
    @IBAction func forgotPasswordbtn(_ sender: UIButton){
        Auth.auth().sendPasswordReset(withEmail: FUser.currentUser()!.email) { (error) in
            if error != nil{
              ProgressHUD.showError("Something went wrong \(error)")
            }else{
                ProgressHUD.showSuccess("check your email's inbox")
            }
        }
    }
    typealias Completion = (Error?) -> Void
    func changePassword(email: String, currentPassword: String, newPassword: String, completion: @escaping Completion) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion:{ user, error in
            if error == nil {
                 Auth.auth().currentUser?.updatePassword(to: newPassword) { (errror) in
                    completion(errror)
                }
            } else {
                completion(error)
            }
        })
    }
    
    
    
}
