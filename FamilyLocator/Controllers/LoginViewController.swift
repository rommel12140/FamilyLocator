  
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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var emailTextField: LoginEmailTextField!
    @IBOutlet weak var passwordTextField: LoginPasswordTextField!
    
    
    @IBOutlet weak var appTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapFunction))
        //assign listener for sign up label
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground")!)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        
        //present register screen
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "RegisterScreen") as! RegisterViewController
        dismiss(animated: true, completion: nil)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func login(_ sender: Any) {
        //signin user with email and password text fields
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                //reference data and get user code
                let reference = Database.database().reference()
                reference.child("uids").child("\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    //present view controller while passing userCode from database
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "mapScreen") as! MapViewController
                    if let userCode = (snapshot.value as AnyObject).value(forKey: "code") as? String{
                        viewController.user = userCode
                        self.present(viewController, animated: true, completion: nil)
                    }
                })
                
            }
        }
        
    }
    
    
  }
