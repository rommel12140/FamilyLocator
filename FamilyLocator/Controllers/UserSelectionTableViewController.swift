//
//  UserSelectionTableViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 20/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import MXParallaxHeader
import MaterialComponents.MaterialBottomSheet
import FirebaseDatabase

class UserSelectionTableViewController: UITableViewController, MXParallaxHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: String!
    var users: Array<String>!
    var familyCodes = Array<String>()
    var familyNames = Array<String>()
    var familyMembers = Array<Array<String>>()
    var memberStatus = Array<Array<String>>()
    var firstName: String!
    var lastName: String!
    var fullname: String!
    let reference = Database.database().reference()

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var accountCode: UILabel!
    @IBOutlet weak var locateButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFamilyCode()
        setup()
        setupHeader()
        displayUserData()
        navBarModifications()
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        setupHeader()
        tableView.parallaxHeader.minimumHeight = view.safeAreaInsets.top + locateButton.frame.height
    }
    
    func setup() {
        tableView.estimatedRowHeight = 100
        
        headerView.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 1).enable()
        // Parallax Header
        tableView.parallaxHeader.view = headerView // You can set the parallax header view from the floating view
        tableView.parallaxHeader.height = 300
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.delegate = self
        
        //header for table view
        // The below line is to eliminate the empty cells
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "headerxib", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "header")
        
    }
    
    func setupHeader() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        changeProfilePictureButton.layer.cornerRadius = changeProfilePictureButton.frame.height/2
    }
    
    func displayUserData(){
        let reference = Database.database().reference()
        if let user = user{
            reference.child("users").child("\(user)" ).observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstname = (snapshot.value as AnyObject).value(forKey: "firstname") as? String, let lastname = (snapshot.value as AnyObject).value(forKey: "lastname") as? String{
                    self.fullNameLabel.text = "\(firstname)  \(lastname)"
                    self.accountCode.text = user
                    self.tableView.reloadData()
                }
                
            })
        }
    }
    
    func getFamilyCode(){
        if let currentUser = user{
            reference.child("users").child("\(currentUser)").child("families").observeSingleEvent(of: .value, with: { (snapshot) in
                //set name
                for (section,familyCode) in snapshot.children.allObjects.enumerated(){
                    self.familyMembers.append([])
                    self.memberStatus.append([])
                    if let fc = familyCode as? DataSnapshot{
                        if let family = fc.value{
                            self.familyCodes.append(family as! String)
                            print("Code: \(self.familyCodes)")
                            //                        self.tableView.reloadData()
                            self.reference.child("family").child("\(family as! String)").child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                                //set name
                                if let name = snapshot.value as? String{
                                    self.familyNames.append(name)
                                    print("Name: \(self.familyNames)")
                                    //                                    self.tableView.reloadData()
                                }
                            }) { print($0) }
                            var index: Int = 0
                            self.reference.child("family").child("\(family)").child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                                //set name
                                print("family: \(family)")
                                
                                for member in (snapshot.children.allObjects as! [DataSnapshot]){
                                    if self.user != (member.value as! String){
                                        self.familyMembers[section].append("")
                                        self.memberStatus[section].append("")
                                        self.reference.child("users").child("\(member.value as! String)").observe(.value, with: { (snapshot) in
                                            //set name
                                            if let name = snapshot.value{
                                                if let fName = (name as AnyObject) .value(forKey: "firstname") as? String, let lName = (name as AnyObject) .value(forKey: "lastname") as? String, let onlineCheck = (name as AnyObject) .value(forKey: "isOnline") as? String {
                                                    self.fullname = ("\(fName) \(lName)")
                                                    self.familyMembers[section][index] = self.fullname
                                                    self.memberStatus[section][index] = onlineCheck
                                                    self.tableView.reloadData()
                                                }
                                            }
                                            index += 1
                                        }) { print($0) }
                                        
                                    }
                                 }
                            }) { print($0) }
                        }
                    }
                }
            }) { print($0) }
        }
    }
    
    func navBarModifications() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        parallaxHeader.view?.blurView.alpha = 1 - parallaxHeader.progress
        if parallaxHeader.progress == 0.000000{
            profileImage.frame.size = CGSize(width: 0, height: 0)
            changeProfilePictureButton.frame.size = CGSize(width: 0, height: 0)
            fullNameLabel.frame.size = CGSize(width: 0, height: 0)
            accountCode.frame.size = CGSize(width: 0, height: 0)
        }
        else{
            profileImage.frame.size = CGSize(width: 100, height: 100)
            changeProfilePictureButton.frame.size = CGSize(width:30, height: 30)
            fullNameLabel.frame.size = CGSize(width: headerView.frame.width, height: 26)
            accountCode.frame.size = CGSize(width: headerView.frame.width, height: 22)
        }
    }
    
    
    @IBAction func locate(_ sender: Any) {
        
        let map = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "mapScreen") as! MapViewController
        map.user = user
        map.users = self.users
        if let navigator = navigationController {
            navigator.pushViewController(map, animated: true)
        }
        
    }
    
    
    @IBAction func showMenu(_ sender: Any) {
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "menuOptions") as! MenuOptionsTableViewController
        viewController.user = user
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height/4)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        print("nipress?")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.contentMode = .scaleAspectFill
            profileImage.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! HeaderXIB
        header.familyName.text = familyNames[section]
        header.familyCode.text = familyCodes[section]
        header.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.6963852048, green: 0.8679255843, blue: 0.8520774245, alpha: 1))
        
        header.familyOptions.addTarget(self, action: #selector(UserSelectionTableViewController.presentBottomSheet), for: .touchUpInside)
        
        return header
    }
    
    @objc func presentBottomSheet( _sender: UIButton) {
        // Initialize the bottom sheet with the view controller just created
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "familyOptions") as! FamilyOptionsViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height/4)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return familyNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return familyMembers[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
        
        cell.membernameLabel.text = familyMembers[indexPath.section][indexPath.row]
        cell.memberImageView.image = UIImage(named: "spiderman")
        
        if memberStatus[indexPath.section][indexPath.row] == "true"{
           cell.memberstatusLabel.text = "status: online"
        }
        else{
            cell.memberstatusLabel.text = "status: offline"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            print(tempUserArray.object(at: indexPath.section))
//            let sec:Int = indexPath.section
//            (tempUserArray[sec] as AnyObject).removeObject(at: indexPath.row)
//            print(tempUserArray)
        }
    }
}

//if let currentUser = user{
//    reference.child("users").child("\(currentUser)").child("families").observeSingleEvent(of: .value, with: { (snapshot) in
//        //set name
//        for (index,familyCode) in snapshot.children.allObjects.enumerated(){
//            if let fc = familyCode as? DataSnapshot{
//                if let family = fc.value{
//                    self.familyCodes.append(family as! String)
//                    print("Code: \(self.familyCodes)")
//                    //                        self.tableView.reloadData()
//                    self.reference.child("family").child("\(family as! String)").child("name").observeSingleEvent(of: .value, with: { (snapshot) in
//                        //set name
//                        if let name = snapshot.value as? String{
//                            print(name)
//                            self.familyNames.append(name)
//                            print("Name: \(self.familyNames)")
//                            //                                    self.tableView.reloadData()
//                        }
//                    }) { print($0) }
//                    self.reference.child("family").child("\(family)").child("members").observeSingleEvent(of: .value, with: { (snapshot) in
//                        //set name
//                        //print(snapshot.value)
//                        for member in snapshot.children.allObjects as! [DataSnapshot]{
//                            self.familyMembers.append("")
//                            self.memberStatus.append("")
//                            if self.user != (member.value as! String){
//                                print(self.familyMembers)
//                                self.reference.child("users").child("\(member.value as! String)").observe(.value, with: { (snapshot) in
//                                    //set name
//                                    if let name = snapshot.value{
//                                        if let fName = (name as AnyObject) .value(forKey: "firstname") as? String, let lName = (name as AnyObject) .value(forKey: "lastname") as? String, let onlineCheck = (name as AnyObject) .value(forKey: "isOnline") as? String {
//                                            self.fullname = ("\(fName) \(lName)")
//                                            self.familyMembers[index] = self.fullname
//                                            self.memberStatus[index] = onlineCheck
//                                            self.tableView.reloadData()
//                                        }
//                                    }
//                                }) { print($0) }
//                            }
//                        }
//                    }) { print($0) }
//                }
//
//            }
//
//
//
//
//
//        }
//    }) { print($0) }
//}
