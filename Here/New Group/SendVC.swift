//
//  SendVC.swift
//  Here
//
//  Created by robin ustarroz on 17/01/2018.
//  Copyright © 2018 robin ustarroz. All rights reserved.
//

import UIKit
import CoreLocation

class SendVC: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var UserIdTextField: UITextField!
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var heading : Double! = 0.0
    var distance : Float = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserIdTextField.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func backButtonIsPressed(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            //CONNECTION A FIREBASE ICI
        }
    }
    
    func updateLocation(_ latitude : Double, _ longitude : Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.distance = Float(location.distance(from: self.userLocation))
    }
    
    @IBAction func sendButtonIsPressed(_ sender: Any) {
        // On get la position du user , on crée sa position en base de donnée, on get l'ID du post et l'affiche dans le textfield
    }
}
