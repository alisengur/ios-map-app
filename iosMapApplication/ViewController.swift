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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!

    
    var addressNameArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createButtonClicked))
        
        getData()
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    

    
    @objc func getData() {
        
        addressNameArray.removeAll(keepingCapacity: false)
        latitudeArray.removeAll(keepingCapacity: false)
        longitudeArray.removeAll(keepingCapacity: false)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject] {
                if let addressName = result.value(forKey: "addressName") as? String {
                    print(addressName)
                    self.addressNameArray.append(addressName)
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
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressNameArray.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewItem", for: indexPath)
        if !addressNameArray[indexPath.row].isEmpty {
            cell.textLabel?.text = "\(addressNameArray[indexPath.row])"
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//          
//          let appDelegate = UIApplication.shared.delegate as! AppDelegate
//          let context = appDelegate.persistentContainer.viewContext
//
//          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
//
//          fetchRequest.predicate = NSPredicate(format: "addressName", "idString")
//
//          fetchRequest.returnsObjectsAsFaults = false
//
//          do {
//              let results = try context.fetch(fetchRequest)
//              if results.count > 0 {
//
//                  for result in results as! [NSManagedObject] {
//                      if let id = result.value(forKey: "id") as? UUID {
//
//                          if id == idArray[indexPath.row] {
//                              context.delete(result)
//                              wordArray.remove(at: indexPath.row)
//                              meaningArray.remove(at: indexPath.row)
//                              self.tableView.reloadData()
//
//                              do {
//                                  try context.save()
//                              } catch {
//                                  print("error")
//                              }
//
//                              break
//
//                          }
//                      }
//                  }
//              }
//          } catch {
//                  print("error")
//          }
//
//      }
//    }
    
    
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let context = appDelegate.persistentContainer.viewContext
//
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
//
//            let idString = addressNameArray[indexPath.row].
//
//            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
//
//            fetchRequest.returnsObjectsAsFaults = false
//
//            do {
//                let results = try context.fetch(fetchRequest)
//                if results.count > 0 {
//
//                    for result in results as! [NSManagedObject] {
//                        if let id = result.value(forKey: "id") as? UUID {
//
//                            if id == idArray[indexPath.row] {
//                                context.delete(result)
//                                wordArray.remove(at: indexPath.row)
//                                meaningArray.remove(at: indexPath.row)
//                                self.tableView.reloadData()
//
//                                do {
//                                    try context.save()
//                                } catch {
//                                    print("error")
//                                }
//
//                                break
//
//                            }
//                        }
//                    }
//                }
//            } catch {
//                    print("error")
//            }
//
//        }
//    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coord = CLLocationCoordinate2D(latitude: latitudeArray[indexPath.row], longitude: longitudeArray[indexPath.row])
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            vc.location = coord
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

