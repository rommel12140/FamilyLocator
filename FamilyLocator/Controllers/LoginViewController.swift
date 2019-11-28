  
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
  
  class LoginViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var signupButton: AuthButton!
    @IBOutlet weak var loginButton: AuthButton!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    //TEMPORARY (SUBSTITUTE FOR USER SELECTION)
    var users = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        scrollView.contentOffset.x = 0
        scrollView.contentSize = CGSize(width: self.scrollView.layer.frame.width, height: self.scrollView.layer.frame.height)
        self.view.addSubview(scrollView)
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.initializeTempUsers()
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    //TEMPORARY (SUBSTITUTE FOR USER SELECTION)
    func initializeTempUsers(){
        //create database reference
        let reference = Database.database().reference()
        reference.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            for a in ((snapshot.value as AnyObject).allKeys)!{
                self.users.append(a as! String)
                
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
                        //TEMPORARY (SUBSTITUTE FOR USER SELECTION)
                        reference.child("users").child("\(userCode)").updateChildValues(["isOnline" : "true"])
                        viewController.user = userCode
//                        viewController.users = self.users
                        self.present(navController, animated: true, completion: {
                            self.view.addSubview(progressHUD)
                            progressHUD.removeFromSuperview()
                            self.view.alpha = 1.0
                            
                            self.loginButton.isEnabled = true
                            self.emailTextField.isEnabled = true
                            self.signupButton.isEnabled = true
                            self.passwordTextField.isEnabled = true
                        })
                    }
                })
                
            }
        }
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
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if(!self.scrollView.isDragging){
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.minX, y: self.view.frame.minY), animated: true)
        }
    }
    
    
  }
