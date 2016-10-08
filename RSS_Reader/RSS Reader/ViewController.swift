//
//  ViewController.swift
//  RSS Reader
//
//  Created by Rohit Singh on 17/07/16.
//  Copyright © 2016 sra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var tblViewFeeds: UITableView!
    
    var arrOfFeeds : [Dictionary<String, AnyObject?>] = []
    var item : [String : AnyObject?] = [:]
    
    var xmlParser :  NSXMLParser!
    
    var element : String!
    var feedLink : String!
    var feedImageURL : String!
    var feedTitle : String!
    var feedDesc : String!


    
    // MARK: View LifeCycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "RSS Feed Reader"
        // Do any additional setup after loading the view, typically from a nib.
        self.tblViewFeeds.delegate = self
        self.tblViewFeeds.dataSource  = self
        let url : NSURL = NSURL(string: "http://news.google.com/?output=rss")!
        
        if Utils.isConnected() {
        xmlParser = NSXMLParser(contentsOfURL: url)
        xmlParser.delegate = self
        xmlParser.shouldResolveExternalEntities = false
            xmlParser.parse()
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
           Utils.showAlertViewOnViewController(self, title: "RSS Feed Reader", message: "No internet connection.")
            
            fetchAllData("Feeds")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view Delegate and DataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfFeeds.count;
       // return 10;

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell :  UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        
        let image : UIImageView = cell.viewWithTag(100)! as! UIImageView
        let lblTitle : UILabel = cell.viewWithTag(200)! as! UILabel
        let lblDesc : UILabel = cell.viewWithTag(300)! as! UILabel
        
        
        if let imageUrl = self.arrOfFeeds[indexPath.row]["imageUrl"] {
            let url : NSURL = NSURL(string: imageUrl as! String)!
            image.setImageWithUrl(url, placeHolderImage: UIImage(named: ""));
        }
        
              let strTitle : String = self.arrOfFeeds[indexPath.row]["title"] as! String;
        lblTitle.text = strTitle
        
        if let strDesc = self.arrOfFeeds[indexPath.row]["feedDesc"] {
            lblDesc.text = strDesc as? String

        }

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let secondView : SecondViewC = storyBoard.instantiateViewControllerWithIdentifier("SecondViewC") as! SecondViewC
        
        if let feedUrl = self.arrOfFeeds[indexPath.row]["feedUrl"] {
            secondView.strUrl = feedUrl as! String
            print(secondView.strUrl)
            self.navigationController?.pushViewController(secondView, animated: true)
        }
        
    }
    
    // MARK: XML Paresr Delegate Methods
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //print(elementName)
        self.element = elementName
        if elementName == "pubDate" {
            self.item = Dictionary<String , AnyObject>()
        } else if elementName == "title"{
            self.feedTitle = ""
            
        } else if elementName == "link" {
            self.feedLink = ""
           
        } else if elementName == "url" {
            self.feedImageURL = ""
        }
        
        else if elementName == "category" {
            self.feedDesc = ""
        }
        
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "title"{
            self.item["title"] = self.feedTitle
        } else if elementName == "url"{
            self.item["imageUrl"] = self.feedImageURL
        } else if elementName == "link"{
        
            self.item["feedUrl"] = self.feedLink
        }  else if elementName == "category" {
            self.item["feedDesc"] = self.feedDesc
            self.arrOfFeeds.append(self.item)

        }
        
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if self.element == "title"{
            self.feedTitle = string
        } else if self.element == "url"{
            self.feedImageURL = string
        } else if self.element == "link" {
            var arrOfStringParts = string.componentsSeparatedByString("=")
            if arrOfStringParts.count > 1 {
                let strUrl = arrOfStringParts[1];
                print(arrOfStringParts)
                self.feedLink = strUrl
            }
        }
        else if self.element == "category" {
            self.feedDesc = string
        }
        else if self.element == "image" {
            //print(string)
            //self.feedDesc = string
            print(string)

        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {

        // Before insertinf data to database, we are deleting all the records
        deleteData("Feeds")
        
        // Getting Managed Object Context Object
        let app : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = app.managedObjectContext
        
        for var dict in arrOfFeeds {
            let feedEntityDesc : NSEntityDescription = NSEntityDescription.entityForName("Feeds", inManagedObjectContext: moc)!
            
            let feeds : Feeds = Feeds(entity: feedEntityDesc, insertIntoManagedObjectContext: moc)
            let strTitle = dict["title"] as! String
            let strDesc = dict["feedDesc"]as! String
            
            feeds.title = strTitle
            feeds.desc = strDesc
            
            
        }
        
        // Finally saving data using Managed Object Context
        do {
            try moc.save()
        } catch let error {
            print("Could not cache the response \(error)")
        }
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        self.tblViewFeeds.reloadData()
    }


    
    // MARK: Core data Delete Method
    
    
     func deleteData(entity:String) {
        
        let app : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = app.managedObjectContext
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: moc)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try moc.executeFetchRequest(fetchRequest) as? [Feeds] {
                for result in results {
                    moc.deleteObject(result)
                }
                
                try moc.save()
            }
        } catch {
           print("failed to clear core data")
        }
    }
    
    // MARK: Core data Getting all data in Offline mode 

    
    func fetchAllData(entity:String) {
        
        self.arrOfFeeds = [Dictionary<String, AnyObject?>]()
        
        let app : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = app.managedObjectContext
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: moc)
        //fetchRequest.includesPropertyValues = false
        
        
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for result in results {
                let feed : Feeds = result as! Feeds
                
                
                self.item = Dictionary<String , AnyObject>()
                                        self.item["title"] = feed.title
                                        self.item["feedDesc"] = feed.desc
                                        self.item["imageUrl"] = nil
                                        self.item["feedUrl"] = nil
                                        self.arrOfFeeds.append(self.item)
            
            }
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        

        self.tblViewFeeds.reloadData()
        
    }

    
    
    
    



}

    





