//
//  InvitationCell.swift
//  FamilyLocator
//
//  Created by DEVG-ODI-2552 on 22/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import MaterialComponents.MDCFloatingButton

protocol NotificationDelegate: class {
    func acceptFamily()
    func declineFamily()
}

class InvitationCell: UITableViewCell {
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var acceptButton: MDCFloatingButton!
    @IBOutlet weak var rejectButton: MDCFloatingButton!
    
    weak var delegate: NotificationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func acceptButton(_ sender: Any) {
        delegate?.acceptFamily()
    }
    
    @IBAction func rejectButton(_ sender: Any) {
        delegate?.declineFamily()
    }
}

//09128946794
//09128946794
