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

struct Member{
    var name: String!
    var firstName: String!
    var status: String!
    var image: UIImage!
    var indexPaths = Array<IndexPath>()
}

struct Family{
    var name: String!
    var members = [String: Member]()
}

class UserSelectionTableViewController: UITableViewController, MXParallaxHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: String!
    var selectedUsers = NSMutableArray()
    var selectedUsersFirstName = NSMutableArray()
    var selectedUsersImages = NSMutableArray()
    var family = [String: Family]()
    var allMembers = [String: Member]()
    var firstName: String!
    var lastName: String!
    var selectedCount = 0
    let reference = Database.database().reference()
    let storageRef = Storage.storage()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var accountCodeTextField: UITextField!
    @IBOutlet weak var locateButton: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        initFamilies()
        setup()
        setupHeader()
        displayUserData()
        navBarModifications()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        background.translatesAutoresizingMaskIntoConstraints = false
        let bgLeading = background.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        let bgTrailing = background.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        background.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        view.addConstraints([bgLeading, bgTrailing])
        
        //        locateButton.translatesAutoresizingMaskIntoConstraints = false
        let locateLeading = locateButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        let locateTrailing = locateButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        view.addConstraints([locateLeading, locateTrailing])
        
        //        fullNameTextField.translatesAutoresizingMaskIntoConstraints = false
        let fNameLeading = fullNameTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        let fNameTrailing = fullNameTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        view.addConstraints([fNameLeading, fNameTrailing])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        setupHeader()
        selectedCount = 0
        selectedUsers.removeAllObjects()
        selectedUsersFirstName.removeAllObjects()
        selectedUsersImages.removeAllObjects()
        locateButton.isEnabled = false
        locateButton.alpha = 0.7
        tableView.reloadData()
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
        
        locateButton.isEnabled = false
        locateButton.alpha = 0.7
        
    }
    
    func setupHeader() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        changeProfilePictureButton.layer.cornerRadius = changeProfilePictureButton.frame.height/2
    }
    
    func displayUserData(){
        if let user = user{
            self.reference.child("users").child("\(user)" ).observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstname = (snapshot.value as AnyObject).value(forKey: "firstname") as? String, let lastname = (snapshot.value as AnyObject).value(forKey: "lastname") as? String{
                    self.firstName = firstname
                    self.lastName = lastname
                    self.fullNameTextField.text = "\(firstname)  \(lastname)"
                    self.accountCodeTextField.text = user
                    self.profileImage.image = UIImage(named: "user-placeholder")
                }
                
                self.tableView.reloadData()
                
            })
            self.reference.child("users").child("\(user)/buffer" ).observe(.value, with: { (snapshot) in
                self.reference.child("users").child("\(user)/imageUrl" ).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get download URL from snapshot
                    if let downloadUrl = snapshot.value as? String{
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
                    }
                    self.tableView.reloadData()
                    
                })
                
            })
        }
    }
    
    func initFamilies(){
        if let currentUser = user{
            reference.child("users").child("\(currentUser)").child("families").observe( .value, with: { (snapshot) in
                self.family.removeAll()
                for familyKey in snapshot.children.allObjects{
                    if let key = (familyKey as? DataSnapshot)?.key as? String{
                        self.addFamily(family: key, userFamiliesSnapshot: snapshot)
                    }
                    
                }
                self.tableView.reloadData()
            })
        }
    }
    
    func addFamily(family: String, userFamiliesSnapshot: DataSnapshot){
        
        self.reference.child("family").child("\(family)").observe( .value, with: { (snapshot) in
            var userFamily = Family()
            if let name = snapshot.childSnapshot(forPath: "name").value as? String{
                userFamily.name = name
                self.family["\(family)"] = userFamily
            }
            self.reference.child("users").child(self.user).child("families").observeSingleEvent(of: .value, with: { (snapshotCheck) in
                if snapshotCheck.hasChild(family){
                    if let snapshotKeys = (snapshot.childSnapshot(forPath: "members").value as? AnyObject)?.allKeys{
                        for snapshotKey in snapshotKeys{
                            if self.user != snapshotKey as? String, let memberKey = snapshotKey as? String{
                                self.getMember(memberKey: memberKey, family: family)
                            }
                        }
                    }
                }
                else{
                    self.family.removeValue(forKey: family)
                    
                }
                self.tableView.reloadData()
            })
            self.tableView.reloadData()
        })
    }
    
    func getMember(memberKey: String, family: String){
        self.reference.child("users").child(memberKey).observe( .value, with: { (snapshot) in
            if let currentMember = snapshot.value{
                if let fName = (currentMember as AnyObject) .value(forKey: "firstname") as? String, let lName = (currentMember as AnyObject) .value(forKey: "lastname") as? String, let isOnline = (currentMember as AnyObject) .value(forKey: "isOnline") as? String {
                    let image = UIImage(named: "user-placeholder")
                    var member = Member()
                    if self.family["\(family)"]?.members["\(memberKey)"] == nil {
                            member.firstName = fName
                            member.name = "\(fName) \(lName)"
                            member.image = image
                            member.status = isOnline
                            self.allMembers["\(memberKey)"] = member
                            self.family["\(family)"]?.members["\(memberKey)"] =  self.allMembers["\(memberKey)"]
                            self.updateUserImage(family: family, memberKey: memberKey)
                    }
                    else{
                        self.family["\(family)"]?.members["\(memberKey)"]?.image = self.allMembers["\(memberKey)"]?.image
                        self.family["\(family)"]?.members["\(memberKey)"]?.status = isOnline
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func updateUserImage(family: String, memberKey: String){
        self.reference.child("users").child("\(memberKey)").child("buffer").observe( .value, with: { (snapshot) in
            self.reference.child("users").child("\(memberKey)").child("imageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get download URL from snapshot
                if let downloadUrl = snapshot.value as? String{
                    // Create a storage reference from the URL
                    let imageStorage = self.storageRef.reference(forURL: downloadUrl)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    imageStorage.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        if error == nil{
//                            let keys = Array(self.family.keys)
//                            let indexOfKey = keys.index(of: family)
//                            let members = Array((self.family[family]?.members.keys)!)
//                            let indexOfMember = members.index(of: memberKey)
//
                                // Create a UIImage, add it to the array
                                self.allMembers["\(memberKey)"]?.image = UIImage(data: data!)!
                                self.family["\(family)"]?.members["\(memberKey)"]?.image = self.allMembers["\(memberKey)"]?.image
                            for indexPath in (self.allMembers[memberKey]?.indexPaths)!{
                                if let cell = self.tableView.cellForRow(at: indexPath) as? MemberTableViewCell{
                                    cell.memberImageView.image = UIImage(data: data!)!
                                }
                            }
                            
                            
                        }
                        
                    }
                }
                
            })
            self.tableView.reloadData()
        })
    }
    
    
    func navBarModifications() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    func parallaxHeaderDidScroll(_ parallaxHeader: MXParallaxHeader) {
        parallaxHeader.view!.blurView.alpha = 1 - parallaxHeader.progress
        if parallaxHeader.progress == 0.000000{
            profileImage.frame.size = CGSize(width: 0, height: 0)
            changeProfilePictureButton.frame.size = CGSize(width: 0, height: 0)
            fullNameTextField.frame.size = CGSize(width: 0, height: 0)
            accountCodeTextField.frame.size = CGSize(width: 0, height: 0)
        }
        else{
            profileImage.frame.size = CGSize(width: 100, height: 100)
            changeProfilePictureButton.frame.size = CGSize(width:30, height: 30)
            fullNameTextField.frame.size = CGSize(width: headerView.frame.width, height: 26)
            accountCodeTextField.frame.size = CGSize(width: headerView.frame.width, height: 22)
        }
    }
    
    
    @IBAction func locate(_ sender: Any) {
        
        let map = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "mapScreen") as! MapViewController
        map.user = user
        map.firstName = self.firstName
        map.userImage = self.profileImage.image
        map.users = self.selectedUsers.mutableCopy() as? Array<String>
        map.userFirstNames =  self.selectedUsersFirstName.mutableCopy() as? Array<String>
        map.userImages = self.selectedUsersImages.mutableCopy() as? Array<UIImage>
        if let navigator = navigationController {
            navigator.pushViewController(map, animated: true)
        }
        
    }
    
    
    @IBAction func showMenu(_ sender: Any) {
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "menuOptions") as! MenuOptionsTableViewController
        viewController.user = user
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: 60*4)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.profileImage.image = UIImage(named: "user-placeholder")
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
        return 70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let keys = Array(self.family.keys)
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! HeaderXIB
        if family.count > 0{
            header.isHidden = false
            header.familyName.text = family[keys[section]]?.name
            
            header.familyCode.text = keys[section]
            header.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.6963852048, green: 0.8679255843, blue: 0.8520774245, alpha: 1))
            
            header.familyOptions.tag = section
            header.familyOptions.addTarget(self, action: #selector(UserSelectionTableViewController.presentBottomSheet(_:)), for: .touchUpInside)
            return header
        }
        else{
            header.isHidden = true
            return header
        }
        
        
    }
    
    @objc func presentBottomSheet(_ sender: Any) {
        let keys = Array(self.family.keys)
        let viewController = UIStoryboard(name: "UserSelection", bundle: nil).instantiateViewController(withIdentifier: "familyOptions") as! FamilyOptionsTableViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        viewController.userCode = self.user
        viewController.familyCode = keys[(sender as AnyObject).tag]
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.width, height: 60*3)
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if family.count == 0{
            return 1
        }
        return family.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = Array(self.family.keys)

        
        if family.count > 0{
            if family[keys[section]]?.members.count == 0{
                return 1
            }
            else{
                return (family[keys[section]]?.members.count)!
            }
        }
        else{
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let keys = Array(self.family.keys)
        
        if family.count > 0{
            let members = Array((self.family[keys[indexPath.section]]?.members.keys)!)
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
            tableView.separatorStyle = .singleLine
            if family[keys[indexPath.section]]?.members.count == 0{
                
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.noMembersLabel.isHidden = false
                cell.membernameLabel.isHidden = true
                cell.memberstatusLabel.isHidden = true
                cell.memberImageView.isHidden = true
                cell.statusIndicator.isHidden = true
            }
                
            else{
                cell.noMembersLabel.isHidden = true
                cell.membernameLabel.isHidden = false
                cell.memberstatusLabel.isHidden = false
                cell.memberImageView.isHidden = false
                cell.statusIndicator.isHidden = false
                cell.isUserInteractionEnabled = true
                cell.selectionStyle = .default
                cell.memberImageView.backgroundColor = .gray
                cell.membernameLabel.text = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.name
                cell.memberImageView.image = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.image
                
                allMembers[members[indexPath.row]]?.indexPaths.append(indexPath)
                
                if family[keys[indexPath.section]]?.members[members[indexPath.row]]?.status == "true"{
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
        else{
            let empty = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! EmptyTableViewCell
            tableView.separatorStyle = .none
            empty.isUserInteractionEnabled = false
            return empty
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = Array(self.family.keys)
        
        
        if family.count > 0, family[keys[indexPath.section]]?.members.count != 0{
            let members = Array((self.family[keys[indexPath.section]]?.members.keys)!)
            
            if selectedUsers.contains(members[indexPath.row]){
                let alert = UIAlertController(title: "Duplicate User",
                                              message: "User already selected.",
                                              preferredStyle: .alert)
                
                //alert with error
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                tableView.cellForRow(at: indexPath)?.isSelected = false
            }
            else{
                if selectedUsers.count > 5{
                    let alert = UIAlertController(title: "Selected Users Exceeded Limit",
                                                  message: "Only 5 users are allowed to be located at once",
                                                  preferredStyle: .alert)
                    
                    //alert with error
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    tableView.cellForRow(at: indexPath)?.isSelected = false
                }
                    
                else{
                    if let key = members[indexPath.row] as? String{
                        selectedUsers.add(key)
                    }
                    if let image = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.image{
                        selectedUsersImages.add(image)
                    }
                    if let firstName = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.firstName{
                        selectedUsersFirstName.add(firstName)
                    }
                    selectedCount += 1
                    
                    if selectedCount > 0{
                        locateButton.isEnabled = true
                        locateButton.alpha = 1
                    }
                    else{
                        locateButton.isEnabled = false
                        locateButton.alpha = 0.7
                    }
                }
            }
           
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let keys = Array(self.family.keys)
        
        if family.count > 0, family[keys[indexPath.section]]?.members.count != 0{
            let members = Array((self.family[keys[indexPath.section]]?.members.keys)!)
            selectedCount -= 1
            
            if selectedCount > 0{
                locateButton.isEnabled = true
                locateButton.alpha = 1
            }
            else{
                locateButton.isEnabled = false
                locateButton.alpha = 0.7
            }
            
            if let key = members[indexPath.row] as? String{
                selectedUsers.remove(key)
            }
            if let image = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.image{
                selectedUsersImages.remove(image)
            }
            if let firstName = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.firstName{
                selectedUsersFirstName.remove(firstName)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let keys = Array(self.family.keys)
        
        if family.count > 0, family[keys[indexPath.section]]?.members.count != 0{
            let members = Array((self.family[keys[indexPath.section]]?.members.keys)!)
            if editingStyle == .delete {
                if let memberKey = members[indexPath.row] as? String, let familyKey = keys[indexPath.section] as? String{
                    self.reference.child("users").child(memberKey).child("families").child(familyKey).removeValue()
                    self.reference.child("family").child(familyKey).child("members").child("\(memberKey)").removeValue()
                    
                    if let fullname = family[keys[indexPath.section]]?.members[members[indexPath.row]]?.name{
                        if let message = "You have removed \(fullname) from \(family[keys[indexPath.section]]?.name as! String)" as? String{
                            self.reference.child("notifications").child(self.user!).child("notifications").childByAutoId().setValue(message)
                        }
                    }
                    if let message2 = "You have been removed from \((family[keys[indexPath.section]]?.name) as! String)" as? String{
                        self.reference.child("notifications").child(memberKey).child("notifications").childByAutoId().setValue(message2)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let keys = Array(self.family.keys)
        if family.count != 0{
            if family[keys[indexPath.section]]?.members.count == 0 {
                return UITableViewCell.EditingStyle.none
            }
            else{
                return UITableViewCell.EditingStyle.delete
            }
        }
        else{
            return UITableViewCell.EditingStyle.none
        }
        
    }
}
