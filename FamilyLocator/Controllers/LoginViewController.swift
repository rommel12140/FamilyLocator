//
//  ViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 11/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var appTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapFunction))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "RegisterScreen")
        
        dismiss(animated: true, completion: nil)
        self.present(vc, animated: true, completion: nil)
        
    }

    @IBAction func login(_ sender: Any) {
        print("Username: \(String(describing: usernameTextField.text))\nPassword: \(String(describing: passwordTextField.text))")
        
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "navScreen")
            
            dismiss(animated: true, completion: nil)
            self.present(vc, animated: true, completion: nil)
        
    }
    

}

