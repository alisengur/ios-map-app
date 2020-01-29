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

    //MARK: -Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .satellite
        }
    }
    
    

    
    //MARK: -Properties
    var location: CLLocationCoordinate2D?
    var willAddNewAnnotation: Bool = false
    var selectedLocation: UITextField?
    let locationManager = CLLocationManager()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        if location != nil {
            confirmButton.isHidden = true
        }
        checkLocationServices()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.segmentControl.selectedSegmentIndex = 0
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
    
    
    
    
    
    //MARK: -Actions
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        let coordinate = self.mapView.convert(self.view.center, toCoordinateFrom: self.mapView)
        print(coordinate)
        let alert = UIAlertController(title: "Are you sure to save?", message: nil, preferredStyle: UIAlertController.Style.alert)   /// creates the alert
        alert.addTextField(configurationHandler: { (textField:UITextField)->Void  in    /// inserts text field to alertview.
                    textField.placeholder = "enter the title of the location"
                })
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) { (_) in
            
            if let titleText = alert.textFields?[0].text, !titleText.isEmpty {
                self.saveLocationToCoreData(location: titleText, latitude: coordinate.latitude, longitude: coordinate.longitude)    /// gets the text and sends to saveLocationWithCoreData function.
            } else {
                print("Title can not blank.")
            }
            
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)    /// shows the alert
        
    }
    
    
    
    
    func saveLocationToCoreData(location: String, latitude: Double, longitude: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        newLocation.setValue(location, forKey: "locationName")
        newLocation.setValue(latitude, forKey: "latitude")
        newLocation.setValue(longitude, forKey: "longitude")
        do {
            try context.save()
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
        if CLLocationManager.locationServicesEnabled() {   /// checks location services is enabled.
            setupLocationManager()
            checkLocationAuthorization()
            
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: /// app can use all location services and receive events while the app is in use.
            mapView.showsUserLocation = true
            centerViewOnUserLocation()  /// set region
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways: ///app can use all location services and receive events even if the user is not aware that your app is running
            break
        

    }
    
    
    
}

}


extension MapViewController: MKMapViewDelegate {

    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {  /// it works when map loaded.
        if let center = location {  /// if location variable exist, setRegion works.
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

