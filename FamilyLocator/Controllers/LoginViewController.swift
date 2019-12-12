  
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
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var showPassword: UIButton!
    
    let reachability = try! Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.emailTextField.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        self.passwordTextField.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        
        //background
        appTitle.textColor = .white
        signupLabel.textColor = .white
        signupButton.backgroundColor = UIColor.commonGreenColor()
        signupButton.setTitleColor(.white, for: UIControl.State.normal)
        loginButton.setTitleColor(UIColor.commonGreenColor(), for: UIControl.State.normal)
        emailTextField.text = ""
        passwordTextField.text = ""
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)

        showPassword.addTarget(self, action: #selector(showPass(_:)), for: .touchDown)
        showPassword.addTarget(self, action: #selector(hidePass(_:)), for: .touchUpInside)
        
        passwordTextField.addTarget(self, action: #selector(isEmptyField), for: .allEvents)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        autoLogin()
    }

    @objc func showPass(_ sender: UIButton){
        passwordTextField.isSecureTextEntry = false
    }
    @objc func hidePass(_ sender: UIButton){
        passwordTextField.isSecureTextEntry = true
    }
    @objc func isEmptyField(_ sender: UITextField){
        if passwordTextField.text != ""{
            showPassword.isHidden = false
        }
        else{
            showPassword.isHidden = true
        }
    }
    
    func autoLogin(){
        let progressHUD = ProgressHUD(text: "Logging in...")
        let blur = UIView.blur(view: self.view)
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            if Auth.auth().currentUser != nil {
                self.view.addSubview(blur)
                self.view.addSubview(progressHUD)
                self.view.isUserInteractionEnabled = false
                let reference = Database.database().reference()
                
                reference.child("uids").child("\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    //present view controller while passing userCode from database
                    let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "userSelection") as! UserSelectionTableViewController
                    let navController = UINavigationController(rootViewController: viewController)
                    if let userCode = (snapshot.value as AnyObject).value(forKey: "code") as? String{
                        reference.child("users").child("\(userCode)").updateChildValues(["isOnline" : "true"])
                        UserDefaults.standard.set(userCode, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        viewController.user = userCode
                        self.present(navController, animated: true, completion: {
                            progressHUD.removeFromSuperview()
                            blur.removeFromSuperview()
                            self.view.isUserInteractionEnabled = true
                        })
                    }
                })
                
            }
        }
        reachability.whenUnreachable = { _ in
            let alert = UIAlertController(title: "Auto-login Failed",
                                          message: "There is no internet connection",
                                          preferredStyle: .alert)
            
            //alert with error
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            progressHUD.removeFromSuperview()
            blur.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewDidLayoutSubviews() {
        appLogo.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30)
        scrollView.contentOffset.x = 0
        scrollView.contentSize = CGSize(width: self.scrollView.layer.frame.width, height: self.contentView.frame.height)
        self.view.addSubview(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    @IBAction func login(_ sender: Any) {
        if checkValid() {
            authenticateUser()
        }
    }
    
    @IBAction func onReturn() {
        self.emailTextField.resignFirstResponder()
        self.view.endEditing(true)
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
        let blur = UIView.blur(view: self.view)
        self.view.addSubview(blur)
        self.view.addSubview(progressHUD)
        self.view.isUserInteractionEnabled = false
        //signin user with email and password text fields
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                progressHUD.removeFromSuperview()
                blur.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
            else{
                //reference data and get user code
                let reference = Database.database().reference()

                reference.child("uids").child("\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    //present view controller while passing userCode from database
                    let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "userSelection") as! UserSelectionTableViewController
                    let navController = UINavigationController(rootViewController: viewController)
                    if let userCode = (snapshot.value as AnyObject).value(forKey: "code") as? String{
                        reference.child("users").child("\(userCode)").updateChildValues(["isOnline" : "true"])
                        viewController.user = userCode
                        self.present(navController, animated: true, completion: {
                            progressHUD.removeFromSuperview()
                            blur.removeFromSuperview()
                            self.view.isUserInteractionEnabled = true
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
