//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    let searchBar = UISearchBar()
    var businesses: [Business]!
    var filteredBusinesses: [Business]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        searchBar.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshBusinesses(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        refreshBusinesses(refreshControl)
    }
    
    func refreshBusinesses(_ refreshControl: UIRefreshControl) {
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
        })
        
        //Example of Yelp search with more search options specified
//        Business.searchWithTerm(term: "Restaurants", sort: .distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]?, error: Error?) in
//            self.businesses = businesses
//            self.filteredBusinesses = businesses
//            self.tableView.reloadData()
//            refreshControl.endRefreshing()
//            
//            /*for business in businesses! {
//                print(business.name!)
//                print(business.address!)
//            }*/
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return filteredBusinesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = filteredBusinesses?[indexPath.row]
        return cell
    }
    
    // called when text starts editing
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.tintColor = UIColor.white
        searchBar.showsCancelButton = true
    }
    
    // called when text changes (including clear)
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBusinesses = searchText.isEmpty ? businesses : businesses.filter({(business: Business) -> Bool in
            let businessName = business.name
            return businessName!.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Yelp"
        self.navigationItem.rightBarButtonItem = self.searchButton
    }
    
    @IBAction func onSearchButtonPress(_ sender: Any) {
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
    }
    
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? DetailViewController
        let cell = sender as? BusinessCell
        let indexPath = tableView.indexPath(for: cell!)
        let business = self.filteredBusinesses?[(indexPath?.row)!]
    }
}
