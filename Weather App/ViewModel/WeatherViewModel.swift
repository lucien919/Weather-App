//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Mac on 11/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import CoreData

class WeatherViewModel {
    private static var locations:[Info]? = []
    private static var zips:[String]? = []
    private static var images:[UIImage]? = []
    private static var currentLocation:Info?
    private static var currentZip:String?
    private static var currentImage:UIImage = #imageLiteral(resourceName: "Default")
    private static var index:Int?
    
    private static var storedLocations:[NSManagedObject]? = []
    
    static func startUp(completion: @escaping ()->()){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName:"WeatherInfo")

        do {
            storedLocations = try managedContext.fetch(request)
        } catch let error {
            print(error.localizedDescription)
        }

        storedLocations?.forEach{
            guard let zip = $0.value(forKey: "zip") as? String else{return}
            callNetwork(zip){
                guard let cl = currentLocation else{return}
                guard let cz = currentZip else{return}
                locations?.append(cl)
                zips?.append(cz)
                callNetwork(nil){
                    images?.append(currentImage)
                }
                completion()
            }
            
        }
        
    }
    
    static func addLocation(){
        guard let cl = currentLocation else{return}
        guard let cz = currentZip else{return}
        locations?.append(cl)
        zips?.append(cz)
        images?.append(currentImage)
        
        saveToCoreData()
    }
    
    private static func saveToCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "WeatherInfo", in: managedContext) else {return}
        let weather = NSManagedObject(entity: entity, insertInto: managedContext)

        guard let z = zips?.last else{return}
        weather.setValue(z, forKey: "zip")

        do {
            try managedContext.save()
            storedLocations?.append(weather)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func removeLocation(){
        guard getCount() > 0 else{return}
        guard let cl = currentLocation else{return}
        var counter:Int = 0
        locations?.forEach{
            if $0.name == cl.name {
                locations?.remove(at: counter)
                zips?.remove(at: counter)
                images?.remove(at: counter)
                
                removeFromCoreData(counter)
            }
            counter += 1
        }
    }
    
    private static func removeFromCoreData(_ indx:Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        guard let val = storedLocations?[indx] else{return}
        managedContext.delete(val)
        storedLocations?.remove(at: indx)

        do{
            try managedContext.save()
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    static func getCount()->Int{
        guard let count = locations?.count else{return 0}
        return count
    }
    
    static func determineIfExists()->Bool{
        guard let cl = currentLocation else{return false}
        
        var returnVal:Bool = false
        locations?.forEach{
            if $0.name == cl.name {
                returnVal = true
            }
        }
        return returnVal
    }
    
    static func callNetwork(_ zip:String?, completion: @escaping ()->()){
        
        guard let z = zip else{
            //guard let index = self.index else{return}
            //guard let icon = locations?[index].weather.first?.icon else{return}
            guard let icon = currentLocation?.weather.first?.icon else{return}
            let fullURL = Networking.iconURLBase+icon+".png"
            
            Networking.getAPI(fullURL, true){
                (val, error) in
                guard error==nil else{return}
                guard let pic = val as? UIImage else{return}
                self.currentImage = pic
                completion()
            }
            return
        }
        
        let fullURL = Networking.baseURL+z+",us&units=imperial&appid=4b77a8ebb74639a773447819601e9363"
        
        Networking.getAPI(fullURL, false){
            (val, error) in
            guard error==nil else{return}
            
            guard let weather = val as? Info else{
                resetCurrentLocation()
                completion()
                return
            }
            self.currentLocation = weather
            self.currentZip = zip
            
            completion()
        }
    }
    
    static func resetCurrentLocation(){
        currentLocation = nil
        currentZip = nil
    }
    
    static func setIndex(_ val:Int){
        guard val < self.locations?.count ?? 0 else{return}
        self.index = val
    }
    
    static func getCityName(_ val:Bool)->String?{
        if(val){
            return currentLocation?.name
        }else{
            guard let index = self.index else{return nil}
            guard index < locations?.count ?? 0 else{return nil}
            return locations?[index].name
        }
    }
    
    static func getWeatherDescription()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        return locations?[index].weather.first?.description
    }
    
    static func getTemperature()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        guard let temp = locations?[index].main.temp else{return nil}
        return "Temp: \(temp) F"
    }
    
    static func getTempMin()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        guard let min = locations?[index].main.min else{return nil}
        return "Min: \(min) F"
    }
    
    static func getTempMax()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        guard let max = locations?[index].main.max else{return nil}
        return "Max: \(max) F"
    }
    
    static func getHumidity()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        guard let hum = locations?[index].main.humidity else{return nil}
        return "Humidity: \(hum)%"
    }
    
    static func getWindSpeed()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        guard let sp = locations?[index].wind.speed else{return nil}
        return "Wind Speed: \(sp) m/hr"
    }
    
    static func getWindDirection()->String?{
        guard let index = self.index else{return nil}
        guard index < locations?.count ?? 0 else{return nil}
        
        guard let degrees = locations?[index].wind.degrees else{return nil}
        
        var direction:String
        switch degrees {
        case 22.6...67.5:
            direction = "NorthEast"
        case 67.6...112.5:
            direction = "East"
        case 112.6...157.5:
            direction = "SouthEast"
        case 157.6...202.5:
            direction = "South"
        case 202.6...247.5:
            direction = "SouthWest"
        case 247.6...292.5:
            direction = "West"
        case 292.6...337.5:
            direction = "NorthWest"
        default:
            direction = "North"
        }
        
        return "Wind Direction: \(direction)"
    }
    
    static func getImageIcon()->UIImage{
        guard let index = self.index else{return #imageLiteral(resourceName: "Default")}
        guard let pic = images?[index] else{return #imageLiteral(resourceName: "Default")}
        return pic
    }
    
    static func updateLocation(completion: @escaping ()->()){
        guard let index = self.index else{return}
        guard let cz = zips?[index] else{return}
        
        
        callNetwork(cz){
            guard let cl = self.currentLocation else{return}
            self.locations?[index] = cl
            callNetwork(nil){
                self.images?[index] = currentImage
            }
            completion()
        }
    }
    
}


















