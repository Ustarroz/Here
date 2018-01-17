//
//  FindVC.swift
//  Here
//
//  Created by robin ustarroz on 17/01/2018.
//  Copyright © 2018 robin ustarroz. All rights reserved.
//

import UIKit

class FindVC: UIViewController, UITextFieldDelegate {

   
    @IBOutlet weak var IdUserTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IdUserTextField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
  
    @IBAction func backButtonIsPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
