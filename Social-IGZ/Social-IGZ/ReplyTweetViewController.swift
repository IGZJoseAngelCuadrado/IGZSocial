//
//  ReplyTweetViewController.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 02/10/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import Foundation
import UIKit
import Social
import Accounts

class ReplyTweetViewController : UIViewController, UITextViewDelegate
{
    var tweetSelected : Tweet
    
    @IBOutlet weak var txtReply: UITextView!

    required init(coder aDecoder: NSCoder)
    {
        tweetSelected = Tweet()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tweetSelected = Singleton.sharedInstance.currentTweet!
        
        self.view.layer.cornerRadius = 8.0
        
        txtReply.text = "@\(tweetSelected.screenName) "
        txtReply.layer.borderColor = UIColor.lightGrayColor().CGColor
        txtReply.layer.borderWidth = 1.0
        txtReply.layer.cornerRadius = 8.0
        txtReply.delegate = self
    }
    
    @IBAction func btnPostTouched(sender: AnyObject)
    {
        
    }
    
    @IBAction func btnCancelTouched(sender: AnyObject)
    {
        var parentView = self.parentViewController as TweetDetailViewController
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            parentView.backgroundView.alpha = 0
            parentView.containerReply.hidden = true
        })
    }
}