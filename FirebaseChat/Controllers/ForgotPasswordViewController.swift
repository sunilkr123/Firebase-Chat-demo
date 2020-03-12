//
//  ForgotPasswordViewController.swift
//  FirebaseChat
//
//  Created by Sunil Kumar on 29/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
import FirebaseFirestore
class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailidtextField: UITextField!
     @IBOutlet weak var resetPassbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        resetPassbtn.layer.cornerRadius = 18
    }
    
    @IBAction func backbtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPassbtn(_ sender: UIButton) {
        if emailidtextField.text! != ""{
            ProgressHUD.show("Sending...")
            Auth.auth().sendPasswordReset(withEmail: emailidtextField.text!) { (error) in
                if error != nil{
                    ProgressHUD.showError("\(error?.localizedDescription)")
                }else{
                    self.emailidtextField.text! = ""
                 ProgressHUD.showSuccess("check your email's inbox")
                }
            }
        }else{
            ProgressHUD.showError("Email id can not be blank!")
        }
        
    }
    
}
