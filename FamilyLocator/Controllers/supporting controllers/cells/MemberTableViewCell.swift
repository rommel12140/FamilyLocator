//
//  MemberTableViewCell.swift
//  FamilyLocator
//
//  Created by Action Trainee on 18/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var membernameLabel: UILabel!
    @IBOutlet weak var memberstatusLabel: UILabel!
    @IBOutlet weak var statusIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        memberImageView.layer.cornerRadius = memberImageView.frame.height/2
        statusIndicator.layer.cornerRadius = statusIndicator.frame.height/2
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
