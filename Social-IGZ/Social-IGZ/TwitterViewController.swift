//
//  FirstViewController.swift
//  Social-IGZ
//
//  Created by Jose Angel Cuadrado Mingo on 09/09/14.
//  Copyright (c) 2014 Jose Angel Cuadrado Mingo. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterViewController: UITableViewController
{
    @IBOutlet weak var addTweet: UIBarButtonItem!
    
    var datasource : NSArray? = []
    let account = ACAccountStore()
    var request : SLRequest?
    var lastTweetSelected : Tweet?
    
    deinit
    {
        datasource = nil
        request = nil
        lastTweetSelected = nil
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchTimelineForUser()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**************************************
        IBActions
    **************************************/
    
    @IBAction func addButtonTouched(sender: UIBarButtonItem)
    {
        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        self.presentViewController(tweetSheet, animated: true, completion: nil);
    }
    
    /**************************************
        TableViewDelegate
    **************************************/
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if datasource == nil
        {
            return 0
        }
        return (datasource!.count >= 20 ? 20 : datasource!.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("FirstCell") as? UITableViewCell
        
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "FirstCell")
        }
        
        var tweetCell = generateTweet(indexPath.row)
        
        cell!.textLabel?.text = "@\(tweetCell.screenName)"
        cell!.textLabel?.font = UIFont.boldSystemFontOfSize(15.0)
        
        cell!.detailTextLabel?.text = "\(tweetCell.text)"
        cell!.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
        cell!.detailTextLabel?.numberOfLines = 4
        
        cell!.imageView?.image = UIImage(data: NSData(contentsOfURL: NSURL(string: tweetCell.photoUserURL)))
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        lastTweetSelected = generateTweet(indexPath.row)
        self.performSegueWithIdentifier("TweetDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "TweetDetail"
        {
            var tweetDetail = segue.destinationViewController as TweetDetailViewController
            tweetDetail.tweetSelected = self.lastTweetSelected!
        }
    }
    
    /**************************************
        Get Data
    **************************************/
    
    func fetchTimelineForUser()
    {
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccountsWithType(accountType, options: nil, completion:
            {(granted: Bool!, error: NSError!) in
                if granted!
                {
                    let arrayOfAccounts = self.account.accountsWithAccountType(accountType)
                    if arrayOfAccounts.count > 0
                    {
                        self.addTweet.enabled = true
                        let twitterAccount:ACAccount = arrayOfAccounts[arrayOfAccounts.count-1] as ACAccount
                        let requestURL = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/home_timeline.json")
                        let parameters = [
                            "count" : "50",
                        ]
                        self.request = SLRequest.init(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters)
                        self.request!.account = twitterAccount
                        self.request!.performRequestWithHandler(
                            {(responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) in
                                var jsonError:NSError?
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                                    self.datasource = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSArray
                                    dispatch_async(dispatch_get_main_queue(),{
                                        if self.datasource != nil
                                        {
                                            if self.datasource!.count != 0
                                            {
                                                println("Timeline Response: \(self.datasource)")
                                                self.tableView.reloadData()
                                                self.refreshControl!.endRefreshing()
                                            }
                                        }
                                        else
                                        {
                                            var alert = UIAlertController(title: "Alerta", message: "Error recuperando la información", preferredStyle: UIAlertControllerStyle.Alert)
                                            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                            self.refreshControl!.endRefreshing()
                                        }
                                    })
                                })
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                            self.addTweet.enabled = false
                            var alert = UIAlertController(title: "Alerta", message: "No hay ninguna cuenta de Twitter asociada a este dispositivo", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
                            dispatch_async(dispatch_get_main_queue(),{
                                self.refreshControl!.endRefreshing()
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                        })
                    }
                }
                else
                {
                    println("Granted error: \(error.localizedDescription)")
                    self.refreshControl!.endRefreshing()
                }
        })
    }
    
    func generateTweet(row: Int) -> Tweet
    {
        var tweet : Tweet?
        
        var tweetDic : NSDictionary! = self.datasource![row] as NSDictionary
        
        if (tweetDic.valueForKey("retweeted_status") != nil)
        {
            var retweet : NSDictionary! = tweetDic.objectForKey("retweeted_status") as NSDictionary
            var idTweet : Int! = retweet.objectForKey("id")?.integerValue
            var textTweet : NSString! = retweet.objectForKey("text") as NSString
            var dateCreationString : NSString! = retweet.objectForKey("created_at") as NSString
            var formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            var dateCreation : NSDate! = formatter.dateFromString(dateCreationString)
            var user : NSDictionary! = retweet.objectForKey("user") as NSDictionary
            var screenNameUser : NSString! = user.objectForKey("screen_name") as NSString
            var nameUser : NSString! = user.objectForKey("name") as NSString
            var photoUser : NSString! = user.objectForKey("profile_image_url_https") as NSString
            
            tweet = Tweet(id: idTweet, text: textTweet, screenName: screenNameUser, name: nameUser, photoUserURL: photoUser, dateCreation: dateCreation)
        }
        else
        {
            var idTweet : Int! = tweetDic.objectForKey("id")?.integerValue
            var textTweet : NSString! = tweetDic.objectForKey("text") as NSString
            var dateCreationString : NSString! = tweetDic.objectForKey("created_at") as NSString
            var formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            var dateCreation : NSDate! = formatter.dateFromString(dateCreationString)
            var user : NSDictionary! = tweetDic.objectForKey("user") as NSDictionary
            var screenNameUser : NSString! = user.objectForKey("screen_name") as NSString
            var nameUser : NSString! = user.objectForKey("name") as NSString
            var photoUser : NSString! = user.objectForKey("profile_image_url_https") as NSString
            
            tweet = Tweet(id: idTweet, text: textTweet, screenName: screenNameUser, name: nameUser, photoUserURL: photoUser, dateCreation: dateCreation)
        }
        
        return tweet!
    }
    
    func refresh(sender:AnyObject)
    {
        fetchTimelineForUser()
    }
}

