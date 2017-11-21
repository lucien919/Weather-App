//
//  ViewController.swift
//  Weather App
//
//  Created by Mac on 11/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class CityTableViewControler: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var cityLabel:UILabel!
    @IBOutlet weak var zipField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        zipField.delegate = self
        
        WeatherViewModel.startUp(){
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func add(_ sender:AnyObject){
        guard cityLabel.text != "Enter Zip Code" else{return}
        guard WeatherViewModel.getCount() < 10 else{
            presentAlert("You have exceeded the max city count of 10")
            reset()
            return
        }
        guard WeatherViewModel.determineIfExists() else{
            guard cityLabel.text != "???" else{
                presentAlert("City already exists or invalid Zip Code")
                reset()
                return
            }
            WeatherViewModel.addLocation()
            reset()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        presentAlert("City already exists or invalid Zip Code")
        reset()
    }
    
    @IBAction func remove(_ sender:AnyObject){
        guard cityLabel.text != "Enter Zip Code" else{return}
        guard WeatherViewModel.determineIfExists() else{
            presentAlert("City does not exist to remove or invalid Zip Code")
            reset()
            return
        }
        WeatherViewModel.removeLocation()
        reset()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reset(){
        cityLabel.text = "Enter Zip Code"
        zipField.text?.removeAll()
        WeatherViewModel.resetCurrentLocation()
    }
    
    func presentAlert(_ message:String){
        let alert  = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }

}

typealias TableViewFunctions = CityTableViewControler
extension TableViewFunctions: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeatherViewModel.getCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") else{fatalError("Cell could not be dequeued")}
        
        WeatherViewModel.setIndex(indexPath.row)
        cell.textLabel?.text = WeatherViewModel.getCityName(false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        WeatherViewModel.setIndex(indexPath.row)
        performSegue(withIdentifier: "CityWeatherSegue", sender: self)
    }
    
}

typealias TextfieldFunctions = CityTableViewControler
extension TextfieldFunctions: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else{return false}
        guard text.count == 5 else{return false}
        
        
        WeatherViewModel.callNetwork(text){
            guard let name = WeatherViewModel.getCityName(true) else{
                DispatchQueue.main.async {
                    self.cityLabel.text = "???"
                }
                return
            }
            WeatherViewModel.callNetwork(nil){}
            DispatchQueue.main.async {
                self.cityLabel.text = name
            }
        }
        
        return true
    }
    
    
}











