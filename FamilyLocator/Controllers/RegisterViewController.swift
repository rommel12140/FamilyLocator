//
//  RegisterViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 12/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

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
        print("Username: \(String(describing: usernameTextField.text))\nPassword: \(String(describing: passwordTextField.text))\nFirst Name: \(String(describing: firstNameTextField.text))\nLast Name: \(String(describing: lastNameTextField.text))")
        
        if usernameTextField.text != nil, passwordTextField.text != nil, confirmPasswordTextField.text != nil, let confirmation = confirmPasswordTextField.text, confirmation == passwordTextField.text, firstNameTextField != nil, lastNameTextField.text != nil {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginScreen")
            
            dismiss(animated: true, completion: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
}
