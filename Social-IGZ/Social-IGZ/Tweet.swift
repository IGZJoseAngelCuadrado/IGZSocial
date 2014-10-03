//
//  Tweet.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 29/09/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import Foundation

class Tweet : NSObject
{
    var text = ""
    var screenName = ""
    var name = ""
    var photoUserURL = ""
    var dateCreation = NSDate.date()
    var idTweet = 0
    
    override init()
    {
        super.init()
    }
    
    init(id: Int, text: String, screenName: String, name: String, photoUserURL: String, dateCreation: NSDate)
    {
        self.idTweet = id
        self.text = text
        self.screenName = screenName
        self.name = name
        self.photoUserURL = photoUserURL
        self.dateCreation = dateCreation
    }
}
