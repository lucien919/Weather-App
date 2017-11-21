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
    @IBOutlet weak var addButton:UIButton!
    @IBOutlet weak var removeButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        aesthetics()
        
        tableView.delegate = self
        tableView.dataSource = self
        zipField.delegate = self
        
        zipField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        WeatherViewModel.startUp(){
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func aesthetics(){
        self.view.backgroundColor = UIColor.black
        tableView.backgroundColor = UIColor.black
        cityLabel.textColor = UIColor.magenta
        addButton.backgroundColor = UIColor.clear
        addButton.setTitleColor(UIColor.magenta, for: .normal)
        addButton.layer.cornerRadius = 2
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.magenta.cgColor
        removeButton.backgroundColor = UIColor.clear
        removeButton.setTitleColor(UIColor.magenta, for: .normal)
        removeButton.layer.cornerRadius = 2
        removeButton.layer.borderWidth = 1
        removeButton.layer.borderColor = UIColor.magenta.cgColor
        zipField.backgroundColor = UIColor.gray
        //zipField.textColor = UIColor.magenta
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
        cell.textLabel?.textColor = UIColor.magenta
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        WeatherViewModel.setIndex(indexPath.row)
        performSegue(withIdentifier: "CityWeatherSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
}

typealias TextfieldFunctions = CityTableViewControler
extension TextfieldFunctions: UITextFieldDelegate{
    
    @objc func textFieldDidChange(){
        guard let text = zipField.text else{return}
        guard text.count == 5 else{
            guard text.count > 5 else{return}
            cityLabel.text = "???"
            return
        }
        
        
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
    }
}











