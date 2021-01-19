//
//  MainTableView.swift
//  MyPlaces
//
//  Created by pro2017 on 18/01/2021.
//

import UIKit

class MainTableView: UITableViewController {

    let restaraunts = [
        "Балкан Гриль", "Бочка", "Вкусные истории", "Speak Easy",
        "Дастархан", "Индокитай", "Bonsai", "Burger Heroes", "Sherlock Holmes",
        "Классик", "Шок", "Kitchen", "Love&Life", "Morris Pub", "X.O",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaraunts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell

        cell.nameLabel.text = restaraunts[indexPath.row]
        cell.imageOfPlace.image = UIImage(named: restaraunts[indexPath.row])
        
        // Делаем изображение круглым
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    
    // MARK: Tabel View Delegate
    
    // Размер одной строки таблицы
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
