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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func signin(_ sender: Any) {
        //redirect to log in after sign in
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
        self.dismiss(animated: true, completion: nil)
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
}
