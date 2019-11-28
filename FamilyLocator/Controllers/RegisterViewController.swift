//
//  RegisterViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 12/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    //IBOUTLETS
    @IBOutlet weak var signInButton: AuthButton!
    @IBOutlet weak var registerButton: AuthButton!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var confirmPasswordTextField: AuthTextField!
    @IBOutlet weak var firstNameTextField: AuthTextField!
    @IBOutlet weak var lastNameTextField: AuthTextField!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentOffset.x = 0
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(scrollView)
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        appTitle.textColor = .white
        signInButton.backgroundColor = UIColor.commonGreenColor()
        signInButton.setTitleColor(.white, for: UIControl.State.normal)
        registerButton.setTitleColor(UIColor.commonGreenColor(), for: UIControl.State.normal)
        
        //background
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    @IBAction func signin(_ sender: Any) {
        //redirect to log in after sign in
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController

        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        //check if fields are empty
        if checkValid(){
            if let confirmation = confirmPasswordTextField.text, confirmation == passwordTextField.text{
                //create user
                createUser(email: emailTextField.text!,password: passwordTextField.text!, firstname: (firstNameTextField.text!), lastname: (lastNameTextField.text!))
                
            }
        }
    }
    
    func createUser(email: String, password: String, firstname: String, lastname: String) {
        let progressHUD = ProgressHUD(text: "Logging in...")
        self.view.addSubview(progressHUD)
        self.view.alpha = 0.9
        
        signInButton.isEnabled = false
        registerButton.isEnabled = false
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        confirmPasswordTextField.isEnabled = false
        firstNameTextField.isEnabled = false
        lastNameTextField.isEnabled = false
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                //create user if valid
                let reference = Database.database().reference()
                var str = self.createRandomHex() //Generate Unique Random Key
                reference.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                    while snapshot.hasChild("\(str)"){
                        //Generate another key if another user already has the key
                        str = self.createRandomHex()
                    }
                    //initialize user with name and location
                    reference.child("users").child("\(str)").setValue(["firstname": firstname, "lastname": lastname])
                    reference.child("location").child(str).setValue(["longitude": 0,"latitude":0])
                })
                reference.child("uids").child("\(user!.user.uid)").setValue(["code": str])
                
                //redirect to log in after sign in
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
                
                self.dismiss(animated: true, completion: nil)
                self.present(vc, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error!.localizedDescription,
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                self.signInButton.isEnabled = false
                self.registerButton.isEnabled = false
                self.emailTextField.isEnabled = false
                self.passwordTextField.isEnabled = false
                self.confirmPasswordTextField.isEnabled = false
                self.firstNameTextField.isEnabled = false
                self.lastNameTextField.isEnabled = false
                self.view.alpha = 1
                progressHUD.removeFromSuperview()
            }
        }
    }

    
    func checkValid() -> Bool{
        var flag = true
        if (emailTextField.text?.isEmpty)!{
            emailTextField.errorMessage = "Please input valid email."
            flag = false
        }
        else if !((emailTextField.text?.contains("@"))!){
            emailTextField.errorMessage = "Invalid email."
            flag = false
        }
        if (passwordTextField.text?.isEmpty)!{
            passwordTextField.errorMessage = "Please input valid password."
            flag = false
        }
        if (confirmPasswordTextField.text?.isEmpty)! || confirmPasswordTextField.text != passwordTextField.text{
            confirmPasswordTextField.errorMessage = "Password does not match."
            flag = false
        }
        if (firstNameTextField.text?.isEmpty)!{
            firstNameTextField.errorMessage = "Please input valid first name."
            flag = false
        }
        if (lastNameTextField.text?.isEmpty)!{
            lastNameTextField.errorMessage = "Please input valid last name."
            flag = false
        }
        
        return flag
    }
    
    //generates random hexadecimal string
    func createRandomHex() -> String{
        return String(format: "%03X%03X", Int(arc4random() % 655), Int(arc4random() % 655))
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if emailTextField.isEditing{
            let buttonAbsoluteY = emailTextField.convert(emailTextField.bounds, to: self.view)
            self.scrollView.setContentOffset(CGPoint(x: emailTextField.bounds.origin.x, y: buttonAbsoluteY.origin.y), animated: true)
        }
        if passwordTextField.isEditing{
            let buttonAbsoluteY = passwordTextField.convert(passwordTextField.bounds, to: self.view)
            self.scrollView.setContentOffset(CGPoint(x: passwordTextField.bounds.origin.x, y: buttonAbsoluteY.origin.y), animated: true)
        }
        if confirmPasswordTextField.isEditing{
            let buttonAbsoluteY = confirmPasswordTextField.convert(confirmPasswordTextField.bounds, to: self.view)
            self.scrollView.setContentOffset(CGPoint(x: confirmPasswordTextField.bounds.origin.x, y: buttonAbsoluteY.origin.y), animated: true)
        }
        if firstNameTextField.isEditing{
            let buttonAbsoluteY = firstNameTextField.convert(firstNameTextField.bounds, to: self.view)
            self.scrollView.setContentOffset(CGPoint(x: firstNameTextField.bounds.origin.x, y: buttonAbsoluteY.origin.y), animated: true)
        }
        if lastNameTextField.isEditing{
            let buttonAbsoluteY = lastNameTextField.convert(lastNameTextField.bounds, to: self.view)
            self.scrollView.setContentOffset(CGPoint(x: lastNameTextField.bounds.origin.x, y: buttonAbsoluteY.origin.y), animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if(!self.scrollView.isDragging){
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.minX, y: self.view.frame.minY), animated: true)
        }
        
    }
}
