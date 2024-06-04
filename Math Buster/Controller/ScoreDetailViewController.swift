//
//  ScoreDetailViewController.swift
//  Math Buster
//
//  Created by Мухаммед Каипов on 11/5/24.
//

import UIKit

class ScoreDetailViewController: UIViewController {

    @IBOutlet var textLabel: UILabel!
    
    var text: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = text
    }


    @IBAction func scoreDetailButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}
