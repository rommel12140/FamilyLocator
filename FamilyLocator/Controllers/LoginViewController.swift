  
  //
  //  ViewController.swift
  //  FamilyLocator
  //
  //  Created by Action Trainee on 11/11/2019.
  //  Copyright © 2019 Action Trainee. All rights reserved.
  //
  import UIKit
  import FirebaseAuth
  import FirebaseDatabase
  import MaterialComponents
  
  class LoginViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var signupButton: AuthButton!
    @IBOutlet weak var loginButton: AuthButton!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var appTitle: UILabel!
    
    //TEMPORARY (SUBSTITUTE FOR USER SELECTION)
    var users = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.scrollView.delegate = self
        
        //TEMPORARY (SUBSTITUTE FOR USER SELECTION)
        initializeTempUsers()
        
        //background
        appTitle.textColor = .white
        signupLabel.textColor = .white
        signupButton.backgroundColor = UIColor.commonGreenColor()
        signupButton.setTitleColor(.white, for: UIControl.State.normal)
        loginButton.setTitleColor(UIColor.commonGreenColor(), for: UIControl.State.normal)
        emailTextField.text = "rommelngallofin@yahoo.com"
        passwordTextField.text = "123456"
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    //TEMPORARY (SUBSTITUTE FOR USER SELECTION)
    func initializeTempUsers(){
        //create database reference
        let reference = Database.database().reference()
        reference.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            for a in ((snapshot.value as AnyObject).allKeys)!{
                self.users.add(a)
            }
        }) { print($0) }
    }
    
    
    
    @IBAction func login(_ sender: Any) {
        if checkValid() {
            authenticateUser()
        }
    }
    
    
    
    func checkValid() -> Bool{
        var flag = true
        
        if (emailTextField.text?.isEmpty)! {
            emailTextField.errorMessage = "Email field is empty."
            flag = false
        }
        else if !((emailTextField.text?.contains("@"))!){
            emailTextField.errorMessage = "Invalid email."
            flag = false
        }
        if (passwordTextField.text?.isEmpty)! {
            passwordTextField.errorMessage = "Password field is empty."
            flag = false
        }
        
        return flag
    }
    
    func authenticateUser(){
        let progressHUD = ProgressHUD(text: "Logging in...")
        self.view.addSubview(progressHUD)
        self.view.alpha = 0.9
        
        loginButton.isEnabled = false
        emailTextField.isEnabled = false
        signupButton.isEnabled = false
        passwordTextField.isEnabled = false
        //signin user with email and password text fields
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                self.loginButton.isEnabled = true
                self.emailTextField.isEnabled = true
                self.signupButton.isEnabled = true
                self.passwordTextField.isEnabled = true
                self.view.alpha = 1
                progressHUD.removeFromSuperview()
            }
            else{
                //reference data and get user code
                let reference = Database.database().reference()
                reference.child("uids").child("\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    //present view controller while passing userCode from database
                    let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "userSelection") as! UserSelectionTableViewController
                    let navController = UINavigationController(rootViewController: viewController)
                    if let userCode = (snapshot.value as AnyObject).value(forKey: "code") as? String{
                        viewController.user = userCode
                        viewController.users = self.users
                        self.present(navController, animated: true, completion: nil)
                    }
                })
                
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                let difference = (-keyboardSize.height + (self.signupButton.frame.maxY) )
                print(self.signupButton.frame.midY)
                print(keyboardSize.height)
                if difference >= 0 {
                        self.view.frame.origin.y -= difference/2
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
  }
