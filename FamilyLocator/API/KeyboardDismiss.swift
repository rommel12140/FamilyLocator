//
//  KeyboardDismiss.swift
//  FamilyLocator
//
//  Created by DEVG-ODI-2552 on 21/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
