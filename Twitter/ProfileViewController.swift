//
//  ProfileViewController.swift
//  Twitter
//
//  Created by CK on 10/6/14.
//  Copyright (c) 2014 Chaitanya Kannali. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController , UITableViewDataSource,UITableViewDelegate ,ProfileUserDelegate{

    @IBOutlet weak var profileTweetsTable: UITableView!
   
    @IBOutlet weak var profileBackGroundImage: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var userHandle: UILabel!
    
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var followingCount: UILabel!
    
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var tweets = [Tweet]()

    var counter:Int? = 20
    var defaultCount:Int? = 20
    var called:Bool = false
    var tweetParams:NSDictionary = NSDictionary()
    
    var profileId:String!
    var profileUser:User!
    var otherProfile:Bool = false
    
    func profileUserDelegate(controller: ProfileViewController, _ item: AnyObject) {
        var user = item as User
        profileUser = user
        otherProfile = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTweetsTable.delegate = self
        profileTweetsTable.dataSource = self
        profileTweetsTable.rowHeight = UITableViewAutomaticDimension
        profileTweetsTable.hidden = true
        if(!otherProfile) {
        profileUser = User.currentUser
 
        }
        profileId = String((profileUser.userid)!)

        tweetParams = ["user_id":profileId]

        refreshTweets()

        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refreshTweets", forControlEvents: UIControlEvents.ValueChanged)
        self.profileTweetsTable.insertSubview(refreshControl, atIndex: 0)
        Store.store("reply.name", val: "")
        Store.store("reply.id" , val: "")
        
        self.profileBackGroundImage.setImageWithURL(NSURL(string:profileUser.profileBackGroundImageUrl!))
        self.profileImage.setImageWithURL(NSURL(string:profileUser.profileImageUrl!))
        self.userFullName.text = profileUser.name
        self.userHandle.text = profileUser.screenName
        self.followingCount.text = String(profileUser.followingCount!)
        self.followersCount.text = String(profileUser.followersCount!)
        
        
        //infinite scrolling
        
        self.profileTweetsTable.addInfiniteScrollingWithActionHandler { () -> Void in
            self.loadMore()
        }
        
    }
    
    func refreshTweets() {
        refreshTweetsWithParams(tweetParams)
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    func refreshTweetsWithParams(params:NSDictionary) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Tweet.tweetsUserTimeLineWithParams(params, completion: { (tweets, error) -> () in
            if(tweets != nil) {
                self.tweets = tweets!
                for tw in tweets! {
                    var t = tw as Tweet
                }
                self.profileTweetsTable.reloadData()
                self.refreshControl.endRefreshing()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.profileTweetsTable.hidden = false
            }
            else {
                NSLog("Error in loading tweets")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    
    
    // Have to track last tweet id - for efficient loading of tweets.
    func loadMore() {
        counter = defaultCount! + counter!
        tweetParams = ["count" : String(counter!), "user_id":profileId]
        refreshTweetsWithParams(tweetParams)
        self.profileTweetsTable.infiniteScrollingView.stopAnimating()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
            }else {
                
            }
            tc.userProfileImage.setImageWithURL(NSURL(string: profileImageUrl!))
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
    
    
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        var tweetSelected = tweets[indexPath.row] as Tweet
//        Tweet.currentTweet = tweetSelected
//        var tdc = self.storyboard?.instantiateViewControllerWithIdentifier("tweetDetailController") as TweetDetailController
//        var segue = UIStoryboardSegue(identifier: "tweetDetailSegue", source: self, destination: tdc)
//        self.prepareForSegue(segue, sender: self)
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
