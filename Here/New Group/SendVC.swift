//
//  SendVC.swift
//  Here
//
//  Created by robin ustarroz on 17/01/2018.
//  Copyright © 2018 robin ustarroz. All rights reserved.
//

import UIKit

class SendVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var UserIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserIdTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}