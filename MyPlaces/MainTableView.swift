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
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)

        cell.textLabel?.text = restaraunts[indexPath.row]
        cell.imageView?.image = UIImage(named: restaraunts[indexPath.row])

        return cell
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
