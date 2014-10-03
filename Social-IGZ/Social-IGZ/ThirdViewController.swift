//
//  ThirdViewController.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 09/09/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import UIKit

class ThirdViewController: UITableViewController {
    
    var colorsList : NSArray?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        colorsList = ["Red" ,"Yellow", "Green", "Blue"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("ThirdCell") as? UITableViewCell
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "ThirdCell")
        }
        
        cell!.textLabel?.text = colorsList![indexPath.row] as? String
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return colorsList!.count
    }
    
}
