//
//  TweetDetailViewController.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 10/09/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import Foundation
import UIKit
import Social
import Accounts

class TweetDetailViewController : UIViewController
{
    @IBOutlet weak var lblScreenName: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblTweet: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnRetweet: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var containerReply: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    internal var tweetSelected : Tweet
    private var request : SLRequest?
    private let account = ACAccountStore()
    
    required init(coder aDecoder: NSCoder)
    {
        tweetSelected = Tweet()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tweetSelected = Singleton.sharedInstance.currentTweet!
        
        lblScreenName.text = "@" + tweetSelected.screenName
        lblName.text = tweetSelected.name
        lblTweet.text = tweetSelected.text
        imgUserProfile.image = UIImage(data: NSData(contentsOfURL: NSURL(string: tweetSelected.photoUserURL)))
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        lblDate.text = formatter.stringFromDate(tweetSelected.dateCreation)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        lblTweet.preferredMaxLayoutWidth = self.view.frame.size.width - (self.lblTweet.frame.origin.x * 2)
    }
    
    @IBAction func btnRetweetTouched(sender: AnyObject)
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
                        let requestURL = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/retweet/\(self.tweetSelected.idTweet).json")
                        let parameters = [
                            "id" : self.tweetSelected.idTweet,
                        ]
                        self.request = SLRequest.init(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: requestURL, parameters: parameters)
                        self.request!.account = twitterAccount
                        self.request!.performRequestWithHandler(
                            {(responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) in
                                if error != nil
                                {
                                    var alert = UIAlertController(title: "Alerta", message: "Error al realizar la acción", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                                else
                                {
                                    self.btnRetweet.enabled = false
                                }
                        })
                    }
                    else
                    {
                        var alert = UIAlertController(title: "Alerta", message: "No hay ninguna cuenta de Twitter asociada a este dispositivo", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    println("Granted error: \(error.localizedDescription)")
                }
        })
    }
    
    @IBAction func btnFavTouched(sender: AnyObject)
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
                        let requestURL = NSURL.URLWithString("https://api.twitter.com/1.1/favorites/create.json?id=\(self.tweetSelected.idTweet)")
                        let parameters = [
                            "id" : self.tweetSelected.idTweet,
                        ]
                        self.request = SLRequest.init(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: requestURL, parameters: parameters)
                        self.request!.account = twitterAccount
                        self.request!.performRequestWithHandler(
                            {(responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) in
                                if error != nil
                                {
                                    var alert = UIAlertController(title: "Alerta", message: "Error al realizar la acción", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                                else
                                {
                                    self.btnFav.enabled = false
                                }
                        })
                    }
                    else
                    {
                        var alert = UIAlertController(title: "Alerta", message: "No hay ninguna cuenta de Twitter asociada a este dispositivo", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    println("Granted error: \(error.localizedDescription)")
                }
        })
    }
    
    @IBAction func btnReplyTouched(sender: AnyObject)
    {        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.backgroundView.alpha = 0.5
            self.containerReply.hidden = false
        })
        
        NSNotificationCenter.defaultCenter().postNotificationName("changeHideValue", object: nil)
    }
    
}
