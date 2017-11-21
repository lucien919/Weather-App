//
//  Networking.swift
//  Weather App
//
//  Created by Mac on 11/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

enum NetworkError:Error{
    case URLDoesNotConnect
    case NoData
    case NoImage
}

class Networking {
    static let baseURL:String = "http://api.openweathermap.org/data/2.5/weather?zip="
    static let iconURLBase:String = "http://openweathermap.org/img/w/"
    
    static func getAPI(_ url:String,_ image:Bool, completion: @escaping (Any?, Error?)->()){
        
        guard let val = URL(string: url) else{return}
        
        let session = URLSession.shared
        
        session.dataTask(with: val){
            (data, response, error) in
            guard error==nil else{
                completion(nil, error)
                return
            }
            guard let data = data else{
                completion(nil, NetworkError.NoData)
                return
            }
            
            var returnVal:Any?
            if(image){
                returnVal = UIImage(data: data)
            }else{
                returnVal = parseWeatherInfo(data)
            }
            
            completion(returnVal, nil)
            
        }.resume()
        
        
    }
    
    private static func parseWeatherInfo(_ data:Data)->Any?{
        do{
            let json = try JSONSerialization.jsonObject(with: data)
            
            guard let dict = json as? [String:Any] else{return nil}
            
            guard let coordDict = dict["coord"] as? [String:Any] else{return nil}
            guard let longitude = coordDict["lon"] as? Double else{return nil}
            guard let latitude = coordDict["lat"] as? Double else{return nil}
            
            let coordinates = Coord(longitude: longitude, latitude: latitude)
            
            
            guard let weatherArr = dict["weather"] as? [[String:Any]] else{return nil}
            
            let weather:[Weather] = weatherArr.flatMap{
                guard let id = $0["id"] as? Int else{return nil}
                guard let main = $0["main"] as? String else{return nil}
                guard let description = $0["description"] as? String else{return nil}
                guard let icon = $0["icon"] as? String else{return nil}
                
                return Weather(id: id, main: main, description: description, icon: icon)
            }
            
            
            guard let base = dict["base"] as? String else{return nil}

            
            guard let mainDict = dict["main"] as? [String:Any] else{return nil}
            guard let temp = mainDict["temp"] as? Double else{return nil}
            guard let pressure = mainDict["pressure"] as? Int else{return nil}
            guard let humidity = mainDict["humidity"] as? Int else{return nil}
            guard let min = mainDict["temp_min"] as? Double else{return nil}
            guard let max = mainDict["temp_max"] as? Double else{return nil}
            
            let main = Main(temp: temp, pressure: pressure, humidity: humidity, min: min, max: max)

            
            guard let visibility = dict["visibility"] as? Int64 else{return nil}

            
            guard let windDict = dict["wind"] as? [String:Any] else{return nil}
            guard let speed = windDict["speed"] as? Double else{return nil}
            guard let degree = windDict["deg"] as? Double else{return nil}
            
            let wind = Wind(speed: speed, degrees: degree)

            
            guard let cloudDict = dict["clouds"] as? [String:Any] else{return nil}
            guard let all = cloudDict["all"] as? Int else{return nil}
            
            let clouds = Clouds(all: all)

            
            var rain:Rain?
            if let rainDict = dict["rain"] as? [String:Any] {
                guard let rainVolume = rainDict["3h"] as? Int else{return nil}
                rain = Rain(h3Volume: rainVolume)
            }
            
            
            var snow:Snow?
            if let snowDict = dict["snow"] as? [String:Any] {
                guard let snowVolume = snowDict["3h"] as? Int else{return nil}
                snow = Snow(h3Volume: snowVolume)
            }
            
            
            guard let dt = dict["dt"] as? Int64 else{return nil}

            
            guard let sysDict = dict["sys"] as? [String:Any] else{return nil}
            guard let type = sysDict["type"] as? Int else{return nil}
            guard let sysId = sysDict["id"] as? Int else{return nil}
            guard let message = sysDict["message"] as? Double else{return nil}
            guard let country = sysDict["country"] as? String else{return nil}
            guard let sunrise = sysDict["sunrise"] as? Int64 else{return nil}
            guard let sunset = sysDict["sunset"] as? Int64 else{return nil}
            
            let sys = System(type: type, id: sysId, message: message, country: country, sunrise: sunrise, sunset: sunset)

            
            guard let id = dict["id"] as? Int else{return nil}
            guard let name = dict["name"] as? String else{return nil}
            guard let cod = dict["cod"] as? Int else{return nil}
            
            return Info(coord: coordinates, weather: weather, base: base, main: main, visibility: visibility, wind: wind, cloud: clouds, rain: rain, snow: snow, dt: dt, sys: sys, id: id, name: name, cod: cod)
            
        }catch let error{
            print("Something went wrong. \(error.localizedDescription)")
        }
        return nil
    }
    
}
