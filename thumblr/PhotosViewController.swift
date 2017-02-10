//
//  PhotosViewController.swift
//  thumblr
//
//  Created by John Law on 2/2/2017.
//  Copyright © 2017 Chi Hon Law. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UILabel!

    let CLIENT_ID = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
    var posts: [NSDictionary] = []

    var isMoreDataLoading = false
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 240;
        tableView.insertSubview(refreshControl, at: 0)
        footerView.isHidden = true

        loadDataFromNetwork()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        print ("refresh")
        loadDataFromNetwork()
        refreshControl.endRefreshing()
    }

    func loadDataFromNetwork() {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(offset)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary

                        if self.isMoreDataLoading && self.posts != [] {
                            // load more data
                            
                            if (responseFieldDictionary["posts"]as! [NSDictionary]).count > 0 {
                                self.posts.append(contentsOf: responseFieldDictionary["posts"] as! [NSDictionary])
                                
                                self.isMoreDataLoading = false
                                self.tableView.reloadData()
                            }
                            
                            else {
                                //show the bottom
                                self.footerView.isHidden = false
                            }
                        }
                        else {
                            // This is where you will store the returned array of posts in your posts property
                            self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                            self.tableView.reloadData()

                        }
                    }
                }
        });
        task.resume()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
        let post = posts[indexPath.row]

        //let timestamp = post["timestamp"] as? String
        let photos = post.value(forKeyPath: "photos") as? [NSDictionary]

        //print ("This is row \(indexPath.row)")

        if photos != nil {
            // photos is NOT nil, go ahead and access element 0 and run the code in the curly braces
            let imageUrlString = photos?[0].value(forKeyPath: "original_size.url") as? String

            if let imageUrl = URL(string: imageUrlString!) {
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                //print (imageUrl)
                cell.photoView.setImageWith(imageUrl)
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
                //print ("URL is nil")
            }

        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
            //print ("Photo is nil")
        }

        //cell.textLabel?.text = "This is row \(indexPath.row)"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let nameVC = NameController()
        //nameVC.fullName = names[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated:true)
        //self.navigationController?.pushViewController(nameVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print ("prepare")
        let vc = segue.destination as! PhotoDetailsViewController
        
        let cell = sender as! PhotoCell
        
        let indexPath = tableView.indexPath(for: cell)

         let post = posts[(indexPath?.row)!]
         
         let photos = post.value(forKeyPath: "photos") as? [NSDictionary]
         
         if photos != nil {
           // photos is NOT nil, go ahead and access element 0 and run the code in the curly braces
            let imageUrlString = photos?[0].value(forKeyPath: "original_size.url") as? String
            
            if let imageUrl = URL(string: imageUrlString!) {
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                vc.imageUrl = imageUrl
            }
            else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
         
         }
         else {
         // photos is nil. Good thing we didn't try to unwrap it!
         }
        
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            //print ("MoreData")
            //isMoreDataLoading = true
            
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                //print ("more")
                isMoreDataLoading = true
                
                // ... Code to load more results ...
                offset += tableView.numberOfRows(inSection: 0)
                loadDataFromNetwork()
            }
            
        }

    }

}
