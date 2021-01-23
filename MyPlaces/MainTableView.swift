//
//  MainTableView.swift
//  MyPlaces
//
//  Created by pro2017 on 18/01/2021.
//

import UIKit

class MainTableView: UITableViewController {

    
    
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        // Упрощаем читабельность кода
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        // Данная конструкция позволяет определить, подставлять значение .image или значение .placeImage!. Если .image == nil, то подставляется изображение из второстепенного массива, если не nil, то подставляется само значение
        if place.image == nil {
            cell.imageOfPlace.image = UIImage(named: place.placeImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
        
        
        // Делаем изображение круглым
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    
    // MARK: Tabel View Delegate
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // unwindSegue от второго экрана
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let addNewPlaceVC = segue.source as? AddNewPlaceViewController else { return }
        addNewPlaceVC.getValueOf()
        places.append(addNewPlaceVC.newPlace!)
        tableView.reloadData()
    }

}
