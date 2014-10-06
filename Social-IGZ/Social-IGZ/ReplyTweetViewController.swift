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
    private var request : SLRequest?
    private let account = ACAccountStore()
    
    @IBOutlet weak var txtReply: UITextView!
    @IBOutlet weak var lblCharacters: UILabel!
    @IBOutlet weak var btnPost: UIButton!

    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
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
        
        lblCharacters.text = String(140 - countElements(txtReply.text))
    }
    
    override func viewWillAppear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterReply:", name: "changeHideValue", object: nil)
    }
    
    func enterReply(Notification: NSNotification)
    {
        txtReply.becomeFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView)
    {
        lblCharacters.text = String(140 - countElements(txtReply.text))
        if countElements(txtReply.text) <= 140
        {
            lblCharacters.textColor = UIColor.blackColor()
            btnPost.enabled = true
        }
        else
        {
            lblCharacters.textColor = UIColor.redColor()
            btnPost.enabled = false
        }
    }
    
    @IBAction func btnPostTouched(sender: AnyObject)
    {
        let accountType = self.account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        self.account.requestAccessToAccountsWithType(accountType, options: nil, completion:
            {(granted: Bool!, error: NSError!) in
                if granted!
                {
                    let arrayOfAccounts = self.account.accountsWithAccountType(accountType)
                    if arrayOfAccounts.count > 0
                    {
                        let twitterAccount:ACAccount = arrayOfAccounts[arrayOfAccounts.count-1] as ACAccount
                        let requestURL = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/update.json?")
                        var parameters = Dictionary<String, AnyObject>()
                        parameters["in_reply_to_status_id"] = "\(self.tweetSelected.idTweet)"
                        parameters["status"] = self.txtReply.text
                        self.request = SLRequest.init(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: requestURL, parameters: parameters)
                        self.request!.account = twitterAccount
                        self.request!.performRequestWithHandler(
                            {(responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) in
                                if error != nil
                                {
                                    var alert = UIAlertController(title: "Alerta", message: "Error al realizar la acción", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    })
                                }
                                else
                                {
                                    self.dismissView()
                                }
                        })
                    }
                    else
                    {
                        var alert = UIAlertController(title: "Alerta", message: "No hay ninguna cuenta de Twitter asociada a este dispositivo", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                        dispatch_async(dispatch_get_main_queue(),{
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                }
                else
                {
                    println("Granted error: \(error.localizedDescription)")
                }
        })
    }
    
    @IBAction func btnCancelTouched(sender: AnyObject)
    {
        self.dismissView()
    }
    
    func dismissView()
    {
        var parentView = self.parentViewController as TweetDetailViewController
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.txtReply.resignFirstResponder()
            parentView.backgroundView.alpha = 0
            parentView.containerReply.hidden = true
        })
    }
}