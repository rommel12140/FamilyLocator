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
import FirebaseStorage

class UserSelectionTableViewController: UITableViewController, MXParallaxHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: String!
    var users: Array<String>!
    var selectedUsers = NSMutableArray()
    var selectedUsersImages = NSMutableArray()
    var familyCodes = Array<String>()
    var familyNames = Array<String>()
    var memberKeys = Array<Array<String>>()
    var familyMembers = Array<Array<String>>()
    var memberStatus = Array<Array<String>>()
    var memberImages = Array<Array<UIImage>>()
    var firstName: String!
    var lastName: String!
    let reference = Database.database().reference()
    let storageRef = Storage.storage()

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
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
        tableView.parallaxHeader.minimumHeight = view.safeAreaInsets.top
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
        
        profileImage.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        profileImage.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        changeProfilePictureButton.layer.cornerRadius = changeProfilePictureButton.frame.height/2
    }
    
    func displayUserData(){
        if let user = user{
            reference.child("users").child("\(user)" ).observe(.value, with: { (snapshot) in
                if let firstname = (snapshot.value as AnyObject).value(forKey: "firstname") as? String, let lastname = (snapshot.value as AnyObject).value(forKey: "lastname") as? String{
                    self.fullNameLabel.text = "\(firstname)  \(lastname)"
                    self.accountCode.text = user
                    
                }
                
                // Get download URL from snapshot
                if let downloadUrl = (snapshot.value as AnyObject).value(forKey: "imageUrl") as? String{
                    // Create a storage reference from the URL
                    let imageStorage = self.storageRef.reference(forURL: downloadUrl)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    imageStorage.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        if error == nil{
                            // Create a UIImage, add it to the array
                            self.profileImage.contentMode = .scaleAspectFill
                            self.profileImage.image = UIImage(data: data!)
                        }
                        else{
                            let alert = UIAlertController(title: "Upload Failed",
                                                          message: "File too big.",
                                                          preferredStyle: .alert)
                            
                            //alert with error
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    self.view.alpha = 1
                    self.view.isUserInteractionEnabled = true
                }
                self.tableView.reloadData()
                
            })
        }
    }
    
    func getFamilyCode(){
        if let currentUser = user{
            reference.child("users").child("\(currentUser)").child("families").observe( .value, with: { (snapshot) in
                //set name
                self.familyMembers = Array<Array<String>>()
                self.memberStatus = Array<Array<String>>()
                self.memberKeys = Array<Array<String>>()
                self.memberImages = Array<Array<UIImage>>()
                self.familyNames = Array<String>()
                self.familyCodes = Array<String>()
                for (section,familyCode) in snapshot.children.allObjects.enumerated(){
                    self.familyMembers.append([])
                    self.memberStatus.append([])
                    self.memberKeys.append([])
                    self.memberImages.append([])
                    
                    if let fc = familyCode as? DataSnapshot{
                        if let family = fc.key as? String{
                            print(family)
                            self.familyCodes.append(family)
                            self.reference.child("family").child("\(family as! String)").child("name").observe( .value, with: { (snapshot) in
                                //set name
                                if let name = snapshot.value as? String{
                                    self.familyNames.append(name)
                                }
                            }) { print($0) }
                            
                            self.reference.child("family").child("\(family)").child("members").observe( .value, with: { (snapshot) in
                                
                                for (index, memberSnap) in (snapshot.children.allObjects.enumerated()){
                                    if let member = memberSnap  as? DataSnapshot{
                                        if self.user != (member.value as! String){
                                            self.reference.child("users").child("\(member.value as! String)").observe(.value, with: { (snapshot) in
                                                //set name
                                                
                                                if let name = snapshot.value{
                                                    if let fName = (name as AnyObject) .value(forKey: "firstname") as? String, let lName = (name as AnyObject) .value(forKey: "lastname") as? String, let onlineCheck = (name as AnyObject) .value(forKey: "isOnline") as? String {
                                                        let fullname = ("\(fName) \(lName)")
                                                        if self.memberKeys[section].contains(member.value as! String){                                                            //self.memberStatus[section][index] = (onlineCheck)
                                                        }
                                                        else{
                                                            self.familyMembers[section].append(fullname)
                                                            self.memberStatus[section].append(onlineCheck)
                                                            self.memberKeys[section].append(member.value as! String)
                                                            self.appendUserImage(currentUser: member.value as! String, section: section)
                                                        }
                                                    }
                                                }
                                                 self.tableView.reloadData()
                                            self.listenToStatus(section: section)
                                            }) { print($0) }
                                        }
                                    }
                                 }
                                
                            }) { print($0) }
                        }
                    }
                }
            }) { print($0) }
        }
    }
    
    func appendUserImage(currentUser: String, section: Int){
        self.memberImages[section].append(UIImage())
        let index = self.memberImages[section].count
        reference.child("users").child("\(currentUser)" ).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get download URL from snapshot
            if let downloadUrl = (snapshot.value as AnyObject).value(forKey: "imageUrl") as? String{
                // Create a storage reference from the URL
                let imageStorage = self.storageRef.reference(forURL: downloadUrl)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                imageStorage.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                    if error == nil{
                        // Create a UIImage, add it to the array
                        self.memberImages[section][index-1] = UIImage(data: data!)!
                        self.tableView.reloadData()
                    }
                    
                }
            }
            
        })
    }
    
    func listenToStatus(section: Int){
        for (index, member) in self.memberKeys[section].enumerated(){
            self.reference.child("users").child("\(member)/isOnline").observe( .value, with: { (snapshot) in
                let isOnline = snapshot.value as? String
                self.memberStatus[section][index] = isOnline!
                self.tableView.reloadData()
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
        map.userImage = self.profileImage.image
        map.users = self.selectedUsers.mutableCopy() as? Array<String>
        map.userImages = self.selectedUsersImages.mutableCopy() as? Array<UIImage>
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
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userCode = user {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let imageStorage = storageRef.reference().child("userImages/\(userCode)")
                let compressedImage = pickedImage.jpegData(compressionQuality: 0.3)
                imageStorage.putData(compressedImage!).observe(.success) { (snapshot) in
                    // When the image has successfully uploaded, we get its download URL
                    if let bucket = snapshot.metadata?.bucket, let name = snapshot.metadata?.name {
                        let downloadUrl = "gs://\(bucket)/userImages/\(name)"
                        // Write the download URL to the Realtime Database
                        let dbRefImg = self.reference.child("users/\(userCode)/imageUrl")
                        dbRefImg.setValue(downloadUrl)
                        let dbRefChg = self.reference.child("users/\(userCode)/buffer")
                        if let autoId = self.reference.childByAutoId().key {
                            dbRefChg.setValue(autoId)
                        }
                    }
                }
            }
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
        if familyMembers[section].isEmpty{
            return 1
        }
        else{
            return familyMembers[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
        
        if familyMembers[indexPath.section].count == 0{
            cell.membernameLabel.text = "No members available yet"
            cell.isUserInteractionEnabled = false
            cell.memberstatusLabel.isHidden = true
            cell.memberImageView.isHidden = true
        }
            
        else{
            cell.memberstatusLabel.isHidden = false
            cell.memberImageView.isHidden = false
            cell.isUserInteractionEnabled = true
            cell.memberImageView.backgroundColor = .gray
            cell.membernameLabel.text = familyMembers[indexPath.section][indexPath.row]
            cell.memberImageView.image = memberImages[indexPath.section][indexPath.row]
            
            if memberStatus[indexPath.section][indexPath.row] == "true"{
                cell.memberstatusLabel.text = "online"
                cell.statusIndicator.backgroundColor = .green
            }
            else{
                cell.memberstatusLabel.text = "offline"
                cell.statusIndicator.backgroundColor = .red
            }
        }
        
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let key = memberKeys[indexPath.section][indexPath.row] as? String{
            selectedUsers.add(key)
        }
        if let image = memberImages[indexPath.section][indexPath.row] as? UIImage{
            selectedUsersImages.add(image)
        }

    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let key = memberKeys[indexPath.section][indexPath.row] as? String{
            selectedUsers.remove(key)
        }
        if let image = memberImages[indexPath.section][indexPath.row] as? UIImage{
            selectedUsersImages.remove(image)
        }

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let memberKey = memberKeys[indexPath.section][indexPath.row] as? String, let familyKey = familyCodes[indexPath.section] as? String{
                print(memberKey + familyKey)
                self.reference.child("family").child(familyKey).child("members").child(memberKey).removeValue()
//                self.reference.child("users").child(memberKey).child("families").removeValue(familyKey)
            }
        }
    }
}
