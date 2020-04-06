//
//  ViewController.swift
//  iosMapApplication
//
//  Created by Ali Şengür on 6.01.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationViewController: UIViewController{
    
    
    @IBOutlet weak var tableView: UITableView!


    var locationNameArray = [String]()
    var cityNameArray = [String]()
    var countryNameArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        setTableView()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "New Location", style: .plain, target: self, action: #selector(createButtonClicked))
        
        getData()
    }
    
    
    fileprivate func setTableView() {
        let tableViewCellNib = UINib(nibName: "LocationTableViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(tableViewCellNib, forCellReuseIdentifier: "LocationTableViewCell")        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    

    
    @objc func getData() {
        
        locationNameArray.removeAll(keepingCapacity: false)
        latitudeArray.removeAll(keepingCapacity: false)
        longitudeArray.removeAll(keepingCapacity: false)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject] {   /// get data from Location entity
                if let addressName = result.value(forKey: "locationName") as? String {
                    self.locationNameArray.append(addressName)   
                }
                
                if let cityName = result.value(forKey: "cityName") as? String {
                    self.cityNameArray.append(cityName)
                }
                
                if let countryName = result.value(forKey: "countryName") as? String {
                    self.countryNameArray.append(countryName)
                }
                
                if let latitude = result.value(forKey: "latitude") as? Double {
                    self.latitudeArray.append(latitude)
                }
                
                if let longitude = result.value(forKey: "longitude") as? Double {
                    self.longitudeArray.append(longitude)
                }
                
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    

    
    
    
    @objc func createButtonClicked() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
}



//MARK: -LocationViewController
extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationNameArray.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        cell.delegate = self
        cell.index = indexPath
        if !locationNameArray[indexPath.row].isEmpty && !cityNameArray[indexPath.row].isEmpty && !countryNameArray[indexPath.row].isEmpty {
            cell.locationNameLabel?.text = "\(locationNameArray[indexPath.row])"
            cell.cityNameLabel.text = "\(cityNameArray[indexPath.row])"
            cell.countryNameLabel.text = "\(countryNameArray[indexPath.row])"
        } else {
            cell.locationNameLabel?.text = ""
            cell.cityNameLabel.text = ""
            cell.countryNameLabel.text = ""
        }
 
        return cell
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {  /// swipe to delete
    
              let appDelegate = UIApplication.shared.delegate as! AppDelegate
              let context = appDelegate.persistentContainer.viewContext
    
              let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                fetchRequest.predicate = NSPredicate(format: "locationName==%@", locationNameArray[indexPath.row])
                /// fetch locations
    
              do {
                  let results = try context.fetch(fetchRequest)
                  if results.count > 0 {
    
                      for result in results as! [NSManagedObject] {
                          if let location = result.value(forKey: "locationName") as? String {
                              if location == locationNameArray[indexPath.row] { /// if location is equal selected index of locationNameArray
                                
                                  context.delete(result)
                                  locationNameArray.remove(at: indexPath.row)
                                  self.cityNameArray.remove(at: indexPath.row)
                                  self.countryNameArray.remove(at: indexPath.row)
                                  self.tableView.reloadData()
    
                                  do {
                                      try context.save()
                                  } catch {
                                      print("error")
                                  }
    
                                  break
    
                              }
                          }
                      }
                  }
              } catch {
                      print("error")
              }
          }
    }
}


extension LocationViewController: LocationCellDelegate {
    func didTappedViewButton(index: Int) {
        let coord = CLLocationCoordinate2D(latitude: latitudeArray[index], longitude: longitudeArray[index])  /// gets coordinates from selected row.
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            vc.location = coord
            self.navigationController?.pushViewController(vc, animated: true)   /// sends coordinates to MapViewController.
        }
        print("tapped")
    }
    
    
}
