//
//  ViewController.swift
//  Here
//
//  Created by robin ustarroz on 15/01/2018.
//  Copyright © 2018 robin ustarroz. All rights reserved.
//

import UIKit
import CoreLocation
import ARKit
import SceneKit
import PusherSwift

class MainVC: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusTextView: UITextView!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var modelNode:SCNNode!
    let rootNodeName = "exclamation"
    var originalTransform:SCNMatrix4!
    let pusher = Pusher(
        key: "c19b7cefebf60fba2525",
        options: PusherClientOptions(authMethod: .inline(secret: "61b8b4233e138ddcf0b2"),host: .cluster("eu"))
    )
    var channel: PusherChannel!
    var heading : Double! = 0.0
    var distance : Float = 0.0 {
        didSet {
            setStatusText()
        }
    }
    var status: String! {
        didSet {
            setStatusText()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        status = "Getting user location"
        statusTextView.textContainerInset = UIEdgeInsets.init(top: 20.0, left: 10.0, bottom: 10.0, right: 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            status = "Connecting to Pusher"
            self.connectToPusher()
        }
    }
    
    func connectToPusher() {
        let channel = pusher.subscribe("private-channel")
        let _ = channel.bind(eventName: "client-new-location", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let latitude = Double(data["latitude"] as! String),
                    let longitude = Double(data["longitude"] as! String),
                    let heading = Double(data["heading"] as! String)  {
                    self.status = "Driver's location received"
                    self.heading = heading
                    self.updateLocation(latitude, longitude)
                }
            }
        })
        pusher.connect()
        status = "Waiting to receive location events..."
    }
    
    func updateLocation(_ latitude : Double, _ longitude : Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.distance = Float(location.distance(from: self.userLocation))
        
        if self.modelNode == nil {
            let modelScene = SCNScene(named: "art.scnassets/exclamation.dae")!
            self.modelNode = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true)!
            let (minBox, maxBox) = self.modelNode.boundingBox
            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
            self.originalTransform = self.modelNode.transform
            positionModel(location)
            sceneView.scene.rootNode.addChildNode(self.modelNode)
            let arrow = makeBillboardNode("⬇️".image()!)
            arrow.position = SCNVector3Make(0, 4, 0)
            self.modelNode.addChildNode(arrow)
        } else {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            positionModel(location)
            SCNTransaction.commit()
        }
    }
    
    func makeBillboardNode(_ image: UIImage) -> SCNNode {
        let plane = SCNPlane(width: 10, height: 10)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    func positionModel(_ location: CLLocation) {
        self.modelNode.transform = rotateNode(Float(-1 * (self.heading - 180).toRadians()), self.originalTransform)
        self.modelNode.position = translateNode(location)
        self.modelNode.scale = scaleNode(location)
    }
    
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
    
    func scaleNode (_ location: CLLocation) -> SCNVector3 {
        let scale = min( max( Float(1000/distance), 1.5 ), 3 )
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform =
            transformMatrix(matrix_identity_float4x4, userLocation, location)
        return positionFromTransform(locationTransform)
    }
    
    func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ driverLocation: CLLocation) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(userLocation, driverLocation)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    func bearingBetweenLocations(_ originLocation: CLLocation, _ driverLocation: CLLocation) -> Double {
        let lat1 = originLocation.coordinate.latitude.toRadians()
        let lon1 = originLocation.coordinate.longitude.toRadians()
        let lat2 = driverLocation.coordinate.latitude.toRadians()
        let lon2 = driverLocation.coordinate.longitude.toRadians()
        let longitudeDiff = lon2 - lon1
        let y = sin(longitudeDiff) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        return atan2(y, x)
    }
    
    func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(
            transform.columns.3.x, transform.columns.3.y, transform.columns.3.z
        )
    }
    
    func setStatusText (){
        var text = "Status: \(status!)\n"
        text += "Distance: \(String(format: "%.2f m", distance))"
        statusTextView.text = text
    }

}

