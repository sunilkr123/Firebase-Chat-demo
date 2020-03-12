//
//  FinishRegistrationViewController.swift
//  FirebaseChat
//
//  Created by MacHD on 10/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class FinishRegistrationViewController: UIViewController , ImagePickerDelegate{
   
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var registerbutton: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailIdtextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    @IBOutlet weak var RegisterView: UIView!
    
    var email: String!
    var password: String!
    var avatarImange: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     avatarImageView.isUserInteractionEnabled = true
        print("\(email) \(password)")
        RegisterView.layer.cornerRadius = 5
        registerbutton.layer.cornerRadius = 18
       
    }


    @IBAction func DoneAction(_ sender: Any) {
       self.view.endEditing(false)
        ProgressHUD.show("Registering...")
        if nameTextField.text != "" && surnameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" && emailIdtextField.text != "" && PasswordTextField.text != "" && ConfirmPasswordTextField.text != ""{
             if PasswordTextField.text == ConfirmPasswordTextField.text {
                FUser.registerUserWith(email: emailIdtextField.text!, password: PasswordTextField.text!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                    if error != nil {
                        ProgressHUD.dismiss()
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    self.registerUser()
                }
            } else {
                ProgressHUD.showError("Passwords dont match!")
            }
            
            
            
            
            
        } else {
            ProgressHUD.showError("All fields are required!")
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Helpers
    func registerUser() {
    let fullName = nameTextField.text! + " " + surnameTextField.text!
    var tempDictionary : Dictionary = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : fullName, kCOUNTRY : countryTextField.text!, kCITY : cityTextField.text!, kPHONE : phoneTextField.text!] as [String : Any]
    if avatarImange == nil {
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
    let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
    let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    tempDictionary[kAVATAR] = avatar
    self.finishRegistration(withValues: tempDictionary)
    }
    } else {
    let avatarData = avatarImange?.jpegData(compressionQuality: 0.5)
    let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    tempDictionary[kAVATAR] = avatar
    self.finishRegistration(withValues: tempDictionary)
        }
    }

    
    func finishRegistration(withValues: [String : Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            self.GotoApp()
           print("error is coming from the server is ",error?.localizedDescription,error.debugDescription)
        }
        
    }

    func GotoApp()  {
        
        //for push notification
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo:[kUSERID : FUser.currentId()])
        
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
       self.present(mainView, animated: true, completion: nil)
    }
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
//MARK: IBActions
@IBAction func avatarImageTap(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
        
       
    }
    
    
    
    @IBAction func cancellButtonPressed(_ sender: Any) {
     self.dismiss(animated: true, completion: nil)
    }

}
