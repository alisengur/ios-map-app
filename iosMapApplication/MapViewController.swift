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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        if location != nil {
            confirmButton.isHidden = true
        }
        
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
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
