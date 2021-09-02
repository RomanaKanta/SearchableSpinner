//
//  ViewController.swift
//  SearchableSpinner
//
//  Created by Romana on 23/8/21.
//

import UIKit

class ViewController: UIViewController, SearchableSpinnerDelegate{
   
    @IBOutlet weak var spinner1: SearchableSpinner!
    @IBOutlet weak var spinner2: SearchableSpinner!
    
    let list = ["Africa", "Antarctica", "Asia", "Europe", "North America",
                "Oceania", "South America", "Zambia", "Vietnam"]
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner1.updateList(list)
        spinner1.spinnerDelegate = self
        spinner2.updateList(list)
        spinner2.spinnerDelegate = self
    }

    func spinnerValue(_ spinner: SearchableSpinner, index:Int, value:String, object: Any){
        print("spinner \(spinner)  value  \(value)" )
    }

}

