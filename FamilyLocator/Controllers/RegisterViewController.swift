//
//  RegisterViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 12/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func register(_ sender: Any) {
        Auth.auth().createUser(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (result, error) in
            if let _eror = error {
                //something bad happning
                print(_eror.localizedDescription )
            }else{
                //user registered successfully
                print(result as Any)
            }
        }
        
        if usernameTextField.text != nil, passwordTextField.text != nil, confirmPasswordTextField.text != nil, let confirmation = confirmPasswordTextField.text, confirmation == passwordTextField.text, firstNameTextField != nil, lastNameTextField.text != nil {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginScreen") as! LoginViewController
            
            dismiss(animated: true, completion: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
}
