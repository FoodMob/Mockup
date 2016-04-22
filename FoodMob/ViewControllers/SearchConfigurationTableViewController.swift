//
//  SearchConfigurationTableViewController.swift
//  FoodMob
//
//  Created by Jonathan Jemson on 3/13/16.
//  Copyright © 2016 FoodMob. All rights reserved.
//

import UIKit

class SearchConfigurationTableViewController: UITableViewController {

    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var priceSelection: UISegmentedControl!
    @IBOutlet weak var starSearch: UISegmentedControl!
    var search = RestaurantSearch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.contentInset.top = -20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if self.locationField.text != "" {
            search.locationString = self.locationField.text
        } else if let location = Session.sharedSession.locationManager.location  {
            search.location = location.coordinate
        } else {
            alert("Location Not Available", message: "FoodMob could not get your current location.")
        }

        search.stars = starSearch.selectedSegmentIndex + 1

        if let destination = segue.destinationViewController as? SearchTableViewController {
            currentDataProvider.fetchRestaurantsForSearch(self.search, withUser: Session.sharedSession.currentUser!, completion: { (restaurants) in
                destination.restaurants = restaurants
            })
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Custom Navigation Bar
        let bar:UINavigationBar! = self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor(hue: 0.5, saturation: 0.851, brightness: 0.959, alpha: 0.0)
        return true
    }
    /**
     Called when the user scrolled the tableView. Updates the headerView and checks to change the navigation bar's backgroundColor to solid or not.
     
     - parameter scrollView: ScrollView
     */
    /*override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= -CGRectGetHeight(customNavigationBarView.frame) {
            customNavigationBarView.adjustBackground(false)
        } else {
            customNavigationBarView.adjustBackground(true)
        }
    }*/

}
