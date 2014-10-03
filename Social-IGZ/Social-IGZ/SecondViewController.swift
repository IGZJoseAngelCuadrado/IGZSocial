//
//  SecondViewController.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 09/09/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    
    var colorsList : NSArray?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        colorsList = ["Facebook" ,"Twitter", "Linkedin"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("SecondCell") as? UITableViewCell
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "SecondCell")
        }
        
        cell!.textLabel?.text = colorsList![indexPath.row] as? String
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return colorsList!.count
    }
    
}

