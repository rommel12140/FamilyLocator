  
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
  
  class LoginViewController: UIViewController {
    
    @IBOutlet weak var signupButton: AuthButton!
    @IBOutlet weak var loginButton: AuthButton!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var appTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //background
        appTitle.textColor = .white
        signupLabel.textColor = .white
        signupButton.backgroundColor = UIColor.commonGreenColor()
        signupButton.setTitleColor(.white, for: UIControl.State.normal)
        loginButton.setTitleColor(UIColor.commonGreenColor(), for: UIControl.State.normal)
        emailTextField.text = "seth@yahoo.com"
        passwordTextField.text = "123456"
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
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
            }
            else{
                //reference data and get user code
                let reference = Database.database().reference()
                reference.child("uids").child("\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    //present view controller while passing userCode from database
                    let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "userSelection") as! UserSelectionTableViewController
                    let navController = UINavigationController(rootViewController: viewController)
                    if let userCode = (snapshot.value as AnyObject).value(forKey: "code") as? String{
                        viewController.users = userCode
                        self.dismiss(animated: true, completion: nil)
                        self.present(navController, animated: true, completion: nil)
                    }
                })
                
            }
        }
    }
    
    
  }
