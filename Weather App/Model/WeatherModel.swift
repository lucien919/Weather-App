//
//  WeatherModel.swift
//  Weather App
//
//  Created by Mac on 11/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

struct Info{
    var coord:Coord
    var weather:[Weather]
    var base:String
    var main:Main
    var visibility:Int64
    var wind:Wind
    var cloud:Clouds
    var rain:Rain?
    var snow:Snow?
    var dt:Int64
    var sys:System
    var id:Int
    var name:String
    var cod:Int
}

struct Coord{
    var longitude:Double
    var latitude:Double
}

struct Weather{
    var id:Int
    var main:String
    var description:String
    var icon:String
}

struct Main{
    var temp:Double
    var pressure:Int
    var humidity:Int
    var min:Double
    var max:Double
}

struct Wind{
    var speed:Double
    var degrees:Double
}

struct Clouds{
    var all:Int
}

struct Rain{
    var h3Volume:Int
}

struct Snow{
    var h3Volume:Int
}

struct System{
    var type:Int
    var id:Int
    var message:Double
    var country:String
    var sunrise:Int64
    var sunset:Int64
}
