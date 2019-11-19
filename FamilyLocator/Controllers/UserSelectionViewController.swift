//
//  UserSelectionViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 12/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class UserSelectionViewController: UIViewController {
    
    let tempFamily:NSArray = ["","CCS Family", "Friends"]
    let tempCodes:NSArray = ["","ccsfamily-1122", "friends-2233"]
    let tempUserArray:NSArray = [[""],["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin"], ["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Rommel Gallofin"]]
    
    @IBOutlet var superView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locateButton: UIButton!
    let profileView = UIView()
    let buttonView = UIButton()
    let backgroundImage = UIImageView()
    let fullnameLabel = UILabel()
    let accountCodeLabel = UILabel()
    let profileImage = UIImageView()
    let changeProfilePicture = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //disable landscape
        setupTable()
        createView()
        addBackground()
        addObjects()
        navBarModifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func setupTable() {
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
//        tableView.backgroundColor = UIColor(named: "white")
        
        // The below line is to eliminate the empty cells
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "headerxib", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "header")
        let buttonNib = UINib(nibName: "buttonxib", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "button")
        tableView.register(buttonNib, forHeaderFooterViewReuseIdentifier: "button")
        
//        locateButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
//        locateButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func createView(){
        profileView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        profileView.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.699224174, green: 0.8759018779, blue: 0.8599839807, alpha: 1))
        profileView.contentMode = .scaleAspectFill
        profileView.clipsToBounds = true
        view.addSubview(profileView)
    }
    
    func addBackground() {
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        profileView.addSubview(backgroundImage)
    }
    
    func addObjects() {
        profileImage.frame = CGRect(x: backgroundImage.frame.midX - 50, y: 100, width: 100, height: 100)
        profileImage.image = UIImage(named: "spiderman")
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 50
        backgroundImage.addSubview(profileImage)
//        superView.sendSubviewToBack(profileImage)
        
        
        changeProfilePicture.frame = CGRect(x: backgroundImage.frame.midX + 20, y: 170, width: 30, height: 30)
        changeProfilePicture.image = UIImage(named: "camera")
        changeProfilePicture.contentMode = .scaleAspectFill
        changeProfilePicture.clipsToBounds = true
        changeProfilePicture.backgroundColor = UIColor(cgColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        changeProfilePicture.layer.cornerRadius = 15
        backgroundImage.addSubview(changeProfilePicture)
        
        fullnameLabel.frame = CGRect(x: backgroundImage.frame.minX, y: 220, width: backgroundImage.frame.width + 10, height: 30)
        fullnameLabel.textAlignment = .center
        fullnameLabel.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        fullnameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        fullnameLabel.text = "full name"
        backgroundImage.addSubview(fullnameLabel)
        
        accountCodeLabel.frame = CGRect(x: backgroundImage.frame.minX, y: 260, width: backgroundImage.frame.width + 10, height: 30)
        accountCodeLabel.textAlignment = .center
        accountCodeLabel.textColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        accountCodeLabel.font = accountCodeLabel.font.withSize(18)
        accountCodeLabel.text = "account code"
        backgroundImage.addSubview(accountCodeLabel)
    }
  
    func navBarModifications() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            let button = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "button") as! ButtonXIB
            
            return button
        default:
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! HeaderXIB
            header.familyName.text = (tempFamily.object(at: section) as! String)
            header.familyCode.text = (tempCodes.object(at: section) as! String)
            header.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.6963852048, green: 0.8679255843, blue: 0.8520774245, alpha: 1))
            
            return header
        }
        // Dequeue with the reuse identifier
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tempFamily.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tempUserArray.object(at: section) as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
        switch indexPath.row % 2 {
        case 0:
            cell.membernameLabel.text = ((tempUserArray.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! String)
            cell.memberImageView.image = UIImage(named: "spiderman")
            cell.memberstatusLabel.text = "Online"
        default:
            cell.contentView.backgroundColor = UIColor.white
            cell.membernameLabel.text = ((tempUserArray.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! String)
            cell.memberImageView.image = UIImage(named: "spiderman")
            cell.memberstatusLabel.text = "Offline"
            cell.membernameLabel.textColor = UIColor(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 60), 400)
        profileView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
}
