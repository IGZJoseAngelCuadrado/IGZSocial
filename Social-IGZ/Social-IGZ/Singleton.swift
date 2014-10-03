//
//  Singleton.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 03/10/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import Foundation

class Singleton
{
    var currentTweet : Tweet?
    
    class var sharedInstance: Singleton
    {
        struct Static
        {
            static var instance: Singleton?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)
        {
            Static.instance = Singleton()
        }
        
        return Static.instance!
    }
}