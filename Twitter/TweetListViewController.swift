//
//  TweetListViewController.swift
//  Twitter
//
//  Created by CK on 9/25/14.
//  Copyright (c) 2014 Chaitanya Kannali. All rights reserved.
//

import UIKit

class TweetListViewController: UIViewController ,UITableViewDataSource , UITableViewDelegate {
    
    @IBOutlet var onProfileTap: UITapGestureRecognizer!
    
    var delegate:ProfileUserDelegate!
    
    @IBOutlet weak var tweetsTable: UITableView!
    var tweets = [Tweet]()
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    var counter:Int? = 20
     var defaultCount:Int? = 20
    var called:Bool = false
    var tweetParams:NSDictionary = NSDictionary()
    var isMentions:Bool = false
    
    @IBOutlet weak var buttonImage: UIButton!
    @IBAction func onTapImgButton(sender: AnyObject) {
        
        var contentView = sender.superview as UIView!
        var tc:TweetCell = contentView.superview  as TweetCell!
     
        var tweet = tc.tweet
        var pvc = self.storyboard?.instantiateViewControllerWithIdentifier("profileViewController") as ProfileViewController
        
        var mvc = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as MainViewController
        
        
        //      mvc.activeViewController = pvc
        var imgV:UIImageView = sender.view as UIImageView
        var tweetInId = imgV.tag
        NSLog("Tag is \(tweetInId)")
        var user = tweet.user as User?
        
        if(tweet.originalUser != nil) {
            user = tweet.originalUser
        }
        Store.store("profile.user", val: String( (user?.userid)!))
        self.delegate = pvc
        delegate.profileUserDelegate(pvc, user!)
        mvc.activeControllerNavigated = pvc
        self.presentViewController(mvc, animated: true, completion: nil)
        
        

        
    }
    
    @IBAction func onProfileTapped(sender: UITapGestureRecognizer) {
//        var imagePosition:CGPoint? = sender.view?.convertPoint(CGPointZero, toView: self.tweetsTable)
//        var indexPath = self.tweetsTable.indexPathForRowAtPoint(imagePosition!)
//        
//        NSLog("Tapped")
//        
//        var pvc = self.storyboard?.instantiateViewControllerWithIdentifier("profileViewController") as ProfileViewController
//    
//        var mvc = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as MainViewController
        
        
//      mvc.activeViewController = pvc
//        var imgV:UIImageView = sender.view as UIImageView
//        NSLog("Tag is # \((indexPath?.row)! )")
//
//        var tweetInId = (indexPath?.row)!
//        NSLog("Tag is \(tweetInId)")
//        var user = tweets[tweetInId].user as User?
//
//        if(tweets[tweetInId].originalUser != nil) {
//            user = tweets[tweetInId].originalUser
//        }
//        Store.store("profile.user", val: String( (user?.userid)!))
//        self.delegate = pvc
//        delegate.profileUserDelegate(pvc, user!)
//        mvc.activeControllerNavigated = pvc
//        self.presentViewController(mvc, animated: true, completion: nil)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        tweetsTable.rowHeight = UITableViewAutomaticDimension
//        tweetParams = ["count" : "100"]
        var ismentions: String = Store.retrieve("is.mentions") as String

        if(ismentions == "yes") {
            isMentions = true
        }
        
        tweetsTable.hidden = true
        refreshTweets()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refreshTweets", forControlEvents: UIControlEvents.ValueChanged)
        self.tweetsTable.insertSubview(refreshControl, atIndex: 0)
        Store.store("reply.name", val: "")
        Store.store("reply.id" , val: "")
        
        
        //infinite scrolling 
        
        self.tweetsTable.addInfiniteScrollingWithActionHandler { () -> Void in
          self.loadMore()
        }
    }
    
    
    // Have to track last tweet id - for efficient loading of tweets.
    func loadMore() {
        counter = defaultCount! + counter!
        tweetParams = ["count" : String(counter!)]
        NSLog("Current counter is \(counter)")
        refreshTweetsWithParams(tweetParams)
        self.tweetsTable.infiniteScrollingView.stopAnimating()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(true)
        refreshTweets()
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        Store.store("reply.name", val: "")
        Store.store("reply.id" , val: "")
        
    }
    

    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func refreshTweets() {
        refreshTweetsWithParams(tweetParams)
    }
    
    func refreshTweetsWithParams(params:NSDictionary) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if(!isMentions) {
        Tweet.tweetsHomeTimeLineWithParams(params, completion: { (tweets, error) -> () in
            if(tweets != nil) {
                NSLog("Tweets Home Line ...")
                self.tweets = tweets!
                for tw in tweets! {
                    var t = tw as Tweet
                }
                self.tweetsTable.reloadData()
                self.refreshControl.endRefreshing()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.tweetsTable.hidden = false
            }
            else {
                NSLog("Error in loading tweets")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.refreshControl.endRefreshing()
            }
        })
            
        } else {
         
            Tweet.tweetsMentionsTimeLineWithParams(params, completion: { (tweets, error) -> () in
                if(tweets != nil) {
                    NSLog("Tweets Mentions Line ...")

                    self.tweets = tweets!
                    for tw in tweets! {
                        var t = tw as Tweet
                    }
                    self.tweetsTable.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.tweetsTable.hidden = false
                }
                else {
                    NSLog("Error in loading tweets")
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
        var tvc = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController") as UIViewController
        self.presentViewController(tvc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func onReply(sender: AnyObject) {
        
    }
    
    
    @IBAction func onFavourite(sender: AnyObject) {
        
        
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
    }
    
    @IBOutlet var onFavourite: UITapGestureRecognizer!
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tc:TweetCell = tableView.dequeueReusableCellWithIdentifier("tweetCellId") as TweetCell
        if(tweets.count > 0 ) {
            var tweet:Tweet = tweets[indexPath.row] as Tweet
            var user:User =  tweet.user!
            tc.tweetText.text = tweet.text
            var profileImageUrl = user.profileImageUrl
            var retweeted:Bool = false
            var userscreenname = user.screenName
            var userfullname = user.name
            if((tweet.originalUser) != nil) {
                retweeted = true
            }
            if(retweeted) {
                profileImageUrl = tweet.originalUser?.profileImageUrl
                userfullname = tweet.originalUser?.name
                userscreenname = tweet.originalUser?.screenName
//                NSLog(" Retweeted post by \(userscreenname)")
            }else {
//                NSLog(" Normal post by \(userscreenname)")
                
            }
            
            tc.userProfileImage.setImageWithURL(NSURL(string: profileImageUrl!))
            tc.buttonImage.imageView?.setImageWithURL(NSURL(string:profileImageUrl!))
            tc.buttonImage.clipsToBounds = true
//            tc.userProfileImage.tag = indexPath.row
//            NSLog("Tagging user : \(userfullname) , with \(indexPath.row)")
            tc.userFullName.text = userfullname
            tc.userName.text = userscreenname
            tc.tweet = tweet
            
            if((tweet.user) != nil && retweeted ) {
                tc.reTweetedByImage.setImageWithURL(NSURL(string:tweet.imageRetweeted))
                tc.reTweetedByy.text = tweet.user?.name
                showRetweeted(tc)
            }else {
               hideRetweeted(tc)
                
            }
            tc.replyImage.setImageWithURL(NSURL(string:tweet.imageReply))
            tc.reTweetActionImage.setImageWithURL(NSURL(string:tweet.imageRetweet))
            tc.favouritesImage.setImageWithURL(NSURL(string:tweet.imageFavourite))
            tc.retweetCnt.text = String(tweet.retweetCount!)
            tc.favCnt.text = String(tweet.favouriteCount!)
            if(tweet.favourited > 0) {
                tc.favouritesImage.setImageWithURL(NSURL(string:tweet.imageFavouriteOn))
            }
            if(tweet.retweeted > 0) {
                tc.reTweetActionImage.setImageWithURL(NSURL(string:tweet.imageRetweeted))
            }
            tc.timeSinceLabel.text = tweet.createdAt?.prettyTimestampSinceNow()
        }
        return tc
    }
    
    
    func hideRetweeted(tc: TweetCell) {
        //CONSTRAINT STUFF
        tc.selfRTConstraint.constant = 0
        tc.selfRTLabelConstraint.constant = 0
        tc.reTweetedByy.hidden = true
        tc.reTweetedByImage.hidden = true
    }
    
    func showRetweeted(tc: TweetCell) {
        //CONSTRAINT STUFF
        tc.selfRTConstraint.constant = 15
        tc.selfRTLabelConstraint.constant = 14
        tc.reTweetedByy.hidden = false
        tc.reTweetedByImage.hidden = false
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var tweet = tweets[indexPath.row] as Tweet

//        var tweetSelected = tweets[indexPath.row] as Tweet
//        Tweet.currentTweet = tweetSelected
//        var tdc = self.storyboard?.instantiateViewControllerWithIdentifier("tweetDetailController") as TweetDetailController
//        var segue = UIStoryboardSegue(identifier: "tweetDetailSegue", source: self, destination: tdc)
//        self.prepareForSegue(segue, sender: self)
        
        var pvc = self.storyboard?.instantiateViewControllerWithIdentifier("profileViewController") as ProfileViewController
        
        var mvc = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as MainViewController
        
        
        //      mvc.activeViewController = pvc
        //        var imgV:UIImageView = sender.view as UIImageView
       
        var user = tweet.user as User?
        
        if(tweet.originalUser != nil) {
            user = tweet.originalUser
        }
        Store.store("profile.user", val: String( (user?.userid)!))
        self.delegate = pvc
        delegate.profileUserDelegate(pvc, user!)
        mvc.activeControllerNavigated = pvc
        self.presentViewController(mvc, animated: true, completion: nil)

    }
    
    
    
    @IBAction func onShowCompose(sender: AnyObject) {
        var tdc = self.storyboard?.instantiateViewControllerWithIdentifier("newTweetController") as NewTweetController
        var segue = UIStoryboardSegue(identifier: "tweetComposeSegue", source: self, destination: tdc)
        self.prepareForSegue(segue, sender: self)
        
    }
    
    // infinite scroll.
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        var actual:CGFloat = scrollView.contentOffset.y
//        var contentHeight:CGFloat = scrollView.contentSize.height - 5
//        NSLog("Actual is \(actual) , Height is \(contentHeight)")
//        if(actual >= contentHeight/2 && !called) {
//            counter = counter! + 100
//            NSLog("Calling refresh on scroll....")
//            refreshTweetsWithParams(["count": String(counter!)])
//            called = true
//            tweetParams = ["count" : counter!]
//        }
//    }
//    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
