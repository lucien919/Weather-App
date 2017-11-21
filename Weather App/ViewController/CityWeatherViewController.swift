//
//  CityWeatherViewController.swift
//  Weather App
//
//  Created by Mac on 11/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class CityWeatherViewController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDirection: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        aesthetics()
        WeatherViewModel.updateLocation(){
            DispatchQueue.main.async {
                self.setUp()
            }
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp(){
        cityNameLabel.text = WeatherViewModel.getCityName(false)
        weatherIcon.image = WeatherViewModel.getImageIcon()
        weatherDescription.text = WeatherViewModel.getWeatherDescription()
        temperature.text = WeatherViewModel.getTemperature()
        minTemp.text = WeatherViewModel.getTempMin()
        maxTemp.text = WeatherViewModel.getTempMax()
        humidity.text = WeatherViewModel.getHumidity()
        windSpeed.text = WeatherViewModel.getWindSpeed()
        windDirection.text = WeatherViewModel.getWindDirection()
    }
    
    func aesthetics(){
        self.view.backgroundColor = UIColor.black
        cityNameLabel.textColor = UIColor.magenta
        weatherDescription.textColor = UIColor.magenta
        temperature.textColor = UIColor.magenta
        minTemp.textColor = UIColor.magenta
        maxTemp.textColor = UIColor.magenta
        humidity.textColor = UIColor.magenta
        windSpeed.textColor = UIColor.magenta
        windDirection.textColor = UIColor.magenta
    }

}
