//
//  MainViewController.swift
//  Twitter
//
//  Created by CK on 10/6/14.
//  Copyright (c) 2014 Chaitanya Kannali. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBAction func onMentions(sender: UIButton) {
        UIView.animateWithDuration(
            0.35, animations: { () -> Void in
                var homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsViewController") as? TweetListViewController
                homeVC?.view.tag = 1
                homeVC?.isMentions = true
                Store.store("is.mentions", val: "yes")
                self.activeViewController = homeVC
                self.centerXConstraint.constant = 0
                self.view.layoutIfNeeded()
        })
        
    }
    var activeControllerNavigated:UIViewController!

    @IBAction func onMyProfile(sender: AnyObject) {
        UIView.animateWithDuration(
            0.35, animations: { () -> Void in
                self.activeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profileViewController") as? UIViewController
                self.centerXConstraint.constant = 0
                self.view.layoutIfNeeded()

        })
        
    }
    @IBOutlet weak var contentView: UIView!
    
    var homeController:TweetListViewController!
    var profileViewController:ProfileViewController!
    var activeViewController : UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVc = oldViewControllerOrNil {
                oldVc.willMoveToParentViewController(nil)
                oldVc.view.removeFromSuperview()
                oldVc.removeFromParentViewController()
            }
            
            if let newVc = activeViewController {
                self.addChildViewController(newVc)
                newVc.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                newVc.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVc.view)
                newVc.didMoveToParentViewController(self)
            }
            
        }
    }
    
    
    @IBOutlet weak var onHome: UIButton!
    
    @IBAction func onHome(sender: UIButton) {
        UIView.animateWithDuration(
            0.35, animations: { () -> Void in
                var homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsViewController") as? TweetListViewController
                homeVC?.view.tag = 0
                homeVC?.isMentions = false
                 self.activeViewController = homeVC
                self.centerXConstraint.constant = 0
                self.view.layoutIfNeeded()
                homeVC?.view.tag = 0
                Store.store("is.mentions", val: "no")


        })
        
        
    }
    
    @IBAction func onSwipe(sender: UISwipeGestureRecognizer) {
        if(sender.state == .Ended) {
            UIView.animateWithDuration(
                0.35, animations: { () -> Void in
                    self.centerXConstraint.constant = -180
                    self.view.layoutIfNeeded()
            })
            
        }
        
    }
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        Store.store("is.mentions", val: "no")

        self.centerXConstraint.constant = 0
        if(activeControllerNavigated != nil ) {
            self.activeViewController = activeControllerNavigated
        }else{
        self.activeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tweetsViewController") as? UIViewController
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
