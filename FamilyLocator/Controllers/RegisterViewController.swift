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
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func register(_ sender: Any) {
        //check if fields are empty
        if !checkEmpty(){
            if let confirmation = confirmPasswordTextField.text, confirmation == passwordTextField.text{
                //create user
                createUser(email: emailTextField.text!,password: passwordTextField.text!, firstname: (firstNameTextField.text!), lastname: (lastNameTextField.text!))
                
            }
        }
    }
    
    func createUser(email: String, password: String, firstname: String, lastname: String) {
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
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
                
                self.dismiss(animated: true, completion: nil)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    
    func checkEmpty() -> Bool{
        var flag = false
        if (emailTextField.text?.isEmpty)!{
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.borderColor = UIColor.red.cgColor
            flag = true
        }
        if (passwordTextField.text?.isEmpty)!{
            passwordTextField.layer.borderWidth = 1
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            flag = true
        }
        if (confirmPasswordTextField.text?.isEmpty)! || confirmPasswordTextField.text != passwordTextField.text{
            confirmPasswordTextField.layer.borderWidth = 1
            confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
            flag = true
        }
        if (firstNameTextField.text?.isEmpty)!{
            firstNameTextField.layer.borderWidth = 1
            firstNameTextField.layer.borderColor = UIColor.red.cgColor
            flag = true
        }
        if (lastNameTextField.text?.isEmpty)!{
            lastNameTextField.layer.borderWidth = 1
            lastNameTextField.layer.borderColor = UIColor.red.cgColor
            flag = true
        }
        
        return flag
    }
    
    //generates random hexadecimal string
    func createRandomHex() -> String{
        return String(format: "%03X%03X", Int(arc4random() % 655), Int(arc4random() % 655))
    }
}
