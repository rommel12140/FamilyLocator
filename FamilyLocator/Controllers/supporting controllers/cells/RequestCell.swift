//
//  RequestCell.swift
//  FamilyLocator
//
//  Created by Action Trainee on 28/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import MaterialComponents.MDCFloatingButton

class RequestCell: UITableViewCell {
    @IBOutlet weak var acceptButton: MDCFloatingButton!
    @IBOutlet weak var rejectButton: MDCFloatingButton!
    @IBOutlet weak var notificationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
