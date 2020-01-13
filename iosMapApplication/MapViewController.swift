//
//  MapViewController.swift
//  iosMapApplication
//
//  Created by Ali Şengür on 6.01.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .satellite
        }
    }
    
    
    @IBOutlet weak var confirmButton: UIButton!
    
    
    var location: CLLocationCoordinate2D?
    var willAddNewAnnotation: Bool = false
    var selectedLocation: UITextField?
    
    
    let locationManager = CLLocationManager()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        //self.mapView.showsUserLocation = true
        if location != nil {
            confirmButton.isHidden = true
        }
        
        checkLocationServices()
        
        
        
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // The best level of accuracy available
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    
    
    
    
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        let coordinate = self.mapView.convert(self.view.center, toCoordinateFrom: self.mapView)
        print(coordinate)
        let alert = UIAlertController(title: "Are you sure to save?", message: nil, preferredStyle: UIAlertController.Style.alert)   // creating the alert
        alert.addTextField(configurationHandler: { (textField:UITextField)->Void  in    // inserting text field to alertview.
                    textField.placeholder = "enter the title of the location"
                })       //Add text field
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) { (_) in
            if let titleText = alert.textFields?[0].text {
                self.saveLocationToCoreData(location: titleText, latitude: coordinate.latitude, longitude: coordinate.longitude)    // getting the text and sending to saveLocationWithCoreData function.
            }
            
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))   // adding the actions
        self.present(alert, animated: true, completion: nil)    // showing the alert
        
    }
    
    
    
    
    func saveLocationToCoreData(location: String, latitude: Double, longitude: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        newLocation.setValue(location, forKey: "locationName")
        newLocation.setValue(latitude, forKey: "latitude")
        newLocation.setValue(longitude, forKey: "longitude")
        do {
            try context.save()  // saving the name, latitude and longitude
            print("successful")
        } catch {
            print("failed")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {   // checks location services is enabled.
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
            // show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // app can use all location services and receive events while the app is in use.
            mapView.showsUserLocation = true
            centerViewOnUserLocation()  // set region
            break
        case .denied:
            // Show alert instructing them how to turn on permission.
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways: //app can use all location services and receive events even if the user is not aware that your app is running
            break
        

    }
    
    
    
}

}


extension MapViewController: MKMapViewDelegate {

    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {  // it works when map loaded.
        if let center = location {  // if location variable exist, setRegion works.
            let regionRadius: CLLocationDistance = 1000.0
            let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius , longitudinalMeters: regionRadius)
            self.mapView.setRegion(region, animated: true)
            self.mapView.showsUserLocation = true
            
        }
    }
}




extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Tells the delegate that new location data is available.  ** Every time the user location updates, it is returning an array of CLLocation. We are adjusting the map view, user is in the center and then we adjust the map view accordingly.
       
       let location = locations.last! as CLLocation
       let currentLocation = location.coordinate
       let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
       mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

