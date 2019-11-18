//
//  UserSelectionViewController.swift
//  FamilyLocator
//
//  Created by Action Trainee on 12/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class UserSelectionViewController: UIViewController {
    
    let tempFamily:NSArray = ["CCS Family", "Friends"]
    let tempCodes:NSArray = ["ccsfamily-1122", "friends-2233"]
    let tempUserArray:NSArray = [["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross", "Nemo Clownfish"], ["Rommel Gallofin", "Dan Chin", "Charles Cariño", "Angel Ross"]]
    
    @IBOutlet var superView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let profileView = UIView()
    let backgroundImage = UIImageView()
    let fullnameLabel = UILabel()
    let accountCodeLabel = UILabel()
    let profileImage = UIImageView()
    let changeProfilePicture = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        setupTable()
        createProfileView()
        addBackground()
        addObjects()
        
    }
    
    func setupTable() {
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.darkGray
    }
    
    func createProfileView() {
        profileView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        profileView.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1))
        profileView.contentMode = .scaleAspectFill
        profileView.clipsToBounds = true
        view.addSubview(profileView)
    }
    
    func addBackground() {
        backgroundImage.image = UIImage(named: "LoginBackground")
        backgroundImage.frame = CGRect(x: 0, y: 0, width: profileView.frame.width, height: UIScreen.main.bounds.size.height)
        profileView.addSubview(backgroundImage)
    }
    
    func addObjects() {
        profileImage.frame = CGRect(x: backgroundImage.frame.midX - 50, y: 100, width: 100, height: 100)
        profileImage.image = UIImage(named: "spiderman")
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 50
        backgroundImage.addSubview(profileImage)
        
        changeProfilePicture.frame = CGRect(x: backgroundImage.frame.midX + 20, y: 170, width: 30, height: 30)
        changeProfilePicture.image = UIImage(named: "camera")
        changeProfilePicture.contentMode = .scaleAspectFill
        changeProfilePicture.clipsToBounds = true
        changeProfilePicture.backgroundColor = UIColor(cgColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (tempFamily[section] as! String)
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
            cell.contentView.backgroundColor = UIColor.darkGray
        default:
            cell.contentView.backgroundColor = UIColor.black
            cell.membernameLabel.text = ((tempUserArray.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! String)
            cell.membernameLabel.textColor = .white
            
            
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 60), 400)
        profileView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
    }
}
