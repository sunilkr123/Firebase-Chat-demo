//
//  WelcomeViewController.swift
//  FirebaseChat
//
//  Created by MacHD on 10/10/19.
//  Copyright © 2019 MacHD. All rights reserved.
//

import UIKit
import ProgressHUD
class WelcomeViewController: UIViewController {

    @IBOutlet weak var txtemailidTextField: UITextField!
    
    @IBOutlet weak var txtPasswordTextField: UITextField!
    @IBOutlet weak var txtRepeatPasswordTextField: UITextField!
    @IBOutlet weak var LoginView: UIView!
    
    @IBOutlet weak var LoginBUtton: UIButton!
    @IBOutlet weak var RgisterButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginView.layer.cornerRadius = 5
        LoginView.dropShadow()
        LoginBUtton.layer.cornerRadius = 18
        RgisterButton.layer.cornerRadius = 18
       
    }
    
    @IBAction func Register(_ sender: UIButton) {
        let bounds = sender.bounds
        UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            sender.bounds = CGRect(x: bounds.origin.x-10, y: bounds.origin.y, width: bounds.size.width+10, height: bounds.size.height+5)
        }) { (success:Bool) in
            UIView.animate(withDuration: 1, animations: {
                sender.bounds = bounds
                self.RegisterUSer()
            })
        }
      
      
    }
    
    @IBAction func Login(_ sender: UIButton) {
        let bounds = sender.bounds
        UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            sender.bounds = CGRect(x: bounds.origin.x-10, y: bounds.origin.y, width: bounds.size.width+30, height: bounds.size.height+5)
        }) { (success:Bool) in
            UIView.animate(withDuration: 1, animations: {
                sender.bounds = bounds
                if self.txtemailidTextField.text != "" && self.txtPasswordTextField.text != ""{
                    self.loginUser()
                }else{
                    ProgressHUD.showError("Email or password is missing")
                }
            })
        }
      
        DisMissKeyboard()
    }
    
    @IBAction func BackgroundTap(_ sender: Any) {
      DisMissKeyboard()
    }
    
    
    
    func DisMissKeyboard()  {
        self.view.endEditing(false)
    }
    
    
    func loginUser() {
        ProgressHUD.show("Login...")
         FUser.loginUserWith(email: txtemailidTextField.text!, password: txtPasswordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                
                return
            }
            ProgressHUD.dismiss()
            self.GotoApp()
           
        }
        
    }
    
    func GotoApp()  {
        
        ///for push notification
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo:[kUSERID : FUser.currentId()])
        
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    func RegisterUSer(){
        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)
        DisMissKeyboard()
        
    }
    
    //MARK: Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "welcomeToFinishReg" {
//            let vc = segue.destination as! FinishRegistrationViewController
//            vc.email = txtemailidTextField.text!
//            vc.password = txtPasswordTextField.text!
        }
        
    }
    
}
extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
