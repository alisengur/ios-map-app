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
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var location: CLLocationCoordinate2D?
    var willAddNewAnnotation: Bool = false
    var selectedCoordinates: CLLocationCoordinate2D?
    // lazy var geocoder = CLGeocoder()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapWillAppear()
        addressTF.isUserInteractionEnabled = false
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    
    
    
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            selectedCoordinates = coordinate
            print(coordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
//            annotation.title = "Title"
//            annotation.subtitle = "subtitle"
            self.mapView.addAnnotation(annotation)
            addressTF.isUserInteractionEnabled = true
        }
    }
    
    
    
    
    
    func mapWillAppear() {
        self.mapView.delegate = self
        guard let cord = self.location else { return }
        let pin = MKPointAnnotation()
        pin.coordinate = cord
        self.mapView.addAnnotation(pin)
        addressTF.isHidden = true
        saveButton.isHidden = true
    }
    
    


    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }

    
    
//    func mapWillAppear() {
//        if willAddNewAnnotation == true {
//            self.mapView.delegate = self
//            guard let cord = self.location else { return }
//            let pin = MKPointAnnotation()
//            pin.coordinate = cord
//            self.mapView.addAnnotation(pin)
//        } else {
//            self.mapView.delegate = self
//        }
//    }
    

    
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {

        guard let coord = self.selectedCoordinates else { return }
        print(coord.latitude)
        print(coord.longitude)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newAddress = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: context)
        
        if let addressName = addressTF.text, addressName.count > 0 {
            newAddress.setValue(addressName, forKey: "addressName")
            newAddress.setValue(coord.latitude, forKey: "latitude")
            newAddress.setValue(coord.longitude, forKey: "longitude")
            
            do {
                try context.save()
                print("successful")
            } catch {
                print("failed")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newData"), object: nil)
            addressTF.text?.removeAll()
            addressTF.isUserInteractionEnabled = false
           // self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Title cannot be blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
}




extension MapViewController: MKMapViewDelegate {

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if let center = location {
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 400, longitudinalMeters: 400)
            self.mapView.setRegion(region, animated: true)
        }
    }
}


















//    func getAddress() {
//
//        let geocoder: CLGeocoder = CLGeocoder()
//        if let selectedLocation = selectedLocation {
//            geocoder.reverseGeocodeLocation(selectedLocation, completionHandler:
//            {(placemarks, error) in
//                if (error != nil)
//                {
//                    print("reverse geodcode fail: \(error!.localizedDescription)")
//                }
//                let pm = placemarks! as [CLPlacemark]
//
//                if pm.count > 0 {
//                    let pm = placemarks![0]
//                    var addressString : String = ""
//                    if pm.subLocality != nil {
//                        addressString = addressString + pm.subLocality! + ", "
//                    }
//                    if pm.thoroughfare != nil {
//                        addressString = addressString + pm.thoroughfare! + ", "
//                    }
//                    if pm.locality != nil {
//                        addressString = addressString + pm.locality! + ", "
//                    }
//                    if pm.country != nil {
//                        addressString = addressString + pm.country! + ", "
//                    }
//
//                    if let subLocality = pm.subLocality,
//                        let thoroughfare = pm.thoroughfare,
//                        let locality = pm.locality,
//                        let country = pm.country
//                    {
//                        self.saveAdress(subLocality: subLocality, thoroughFare: thoroughfare, locality: locality, country: country)
//                    }
//                    print(addressString)
//                }
//            })
//        }
//    }
    
    

//    func saveAdress(subLocality: String, thoroughFare: String, locality: String, country: String ) {
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//
//        let newAddress = NSEntityDescription.insertNewObject(forEntityName: "Address", into: context)
//        newAddress.setValue(subLocality, forKey: "subLocality")
//        newAddress.setValue(thoroughFare, forKey: "thoroughFare")
//        newAddress.setValue(locality, forKey: "locality")
//        newAddress.setValue(country, forKey: "country")
//
//        do {
//            try context.save()
//            print("successful")
//        } catch {
//            print("failed")
//        }
//
//
//    }
