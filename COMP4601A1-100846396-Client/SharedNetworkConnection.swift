//
//  SharedNetworkConnection.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

class SharedNetworkConnection: NSObject, NSURLSessionDataDelegate {
    
    //Creating Singleton instance of the class
    class var sharedInstance: SharedNetworkConnection {
        struct Static {
            static var instance: SharedNetworkConnection?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SharedNetworkConnection()
        }
        
        return Static.instance!
    }
    
    // MARK: - Assignment 1
    
    /**
    Creates an HTTP POST with a Document as XML for the body. Creates a new document. Parses the response code and notifys
    any listening controllers.
    */
    func createDocumentOnServer(name: String, text: String, tags: String, links: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appCreate)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let xmlTags: StringBuilder = StringBuilder()
        let xmlLinks: StringBuilder = StringBuilder()
        let tagsArray: [String] = SharedHelper.buildTagsArrayFromString(tags)
        var linksArray: [String] = SharedHelper.buildLinksArrayFromString(links)
        linksArray.removeAtIndex(0)
        
        for s in tagsArray {
            xmlTags.append("<tags>" + s + "</tags>")
        }
        
        for l in linksArray {
            xmlLinks.append("<links>" + l + "</links>")
        }
        
        println(xmlTags.toString())
        println(xmlLinks.toString())
        
        let xmlString: String = "<?xml version=\"1.0\" ?>\n" + "<Document>" +
            "<name>" + name + "</name>" +
            "<text>" + text + "</text>" +
            xmlTags.toString() +
            xmlLinks.toString() +
        "</Document>"
        
        let data : NSData = (xmlString).dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
                
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Created"
                } else if (httpResponse.statusCode == 204) {
                    result = "Document Creation Failed: No Content"
                } else if (httpResponse.statusCode == 406) {
                    result = "Document Creation Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "Document Creation Failed: Link Not Found"
                } else {
                    result = "Document Creation Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("CREATE", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates an HTTP PUT with a Document as XML for the body. Updates a document. Parses the response code and notifys
    any listening controllers.
    */
    func updateDocumentOnServer(id: String, tags: String, links: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appUpdate + id)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        let xmlTags: StringBuilder = StringBuilder()
        let xmlLinks: StringBuilder = StringBuilder()
        let tagsArray: [String] = SharedHelper.buildTagsArrayFromString(tags)
        var linksArray: [String] = SharedHelper.buildLinksArrayFromString(links)
        linksArray.removeAtIndex(0)
        
        for s in tagsArray {
            xmlTags.append("<tags>" + s + "</tags>")
        }
        
        for l in linksArray {
            xmlTags.append("<links>" + l + "</links>")
        }
        
        let xmlString: String = "<Document>" +
            xmlTags.toString()  +
            xmlLinks.toString() +
        "</Document>"
        
        let data : NSData = (xmlString).dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Update"
                } else if(httpResponse.statusCode == 204){
                    result = "Document Update Failed: Document Not Found"
                } else if (httpResponse.statusCode == 406) {
                    result = "Document Update Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "Document Update Failed: Link Not Found"
                } else {
                    result = "Document Update Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("UPDATE", object: nil, userInfo: dictionary)
            }
        })
        
        task.resume()
    }
    
    /**
    Creates an HTTP DELETE with a Document Id. Deletes the document. Parses the response code and notifys
    any listening controllers.
    */
    func deleteDocumentOnServer(id: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appDelete + id)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Removed"
                } else if (httpResponse.statusCode == 204) {
                    result = "Document Removal Failed: No Content"
                } else if (httpResponse.statusCode == 406) {
                    result = "Document Removal Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "Document Removal Failed: Link Not Found"
                } else {
                    result = "Document Removal Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("DELETE", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates an HTTP GET with a Document as XML for the body. Sends the HTML to
    any listening controllers.
    */
    func getDocumentOnServer(id: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appView + id)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("VIEW", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates an HTTP GET with a Document Id. Sends the parsed XML doc to
    any listening controllers.
    */
    func getDocumentOnServerXML(id: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appView + id)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Accept")
        
        println("sent")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("VIEW-XML", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates an HTTP GET with a tag string. Parses the response code to
    any listening controllers.
    */
    func deleteMultipleDocumentsOnServer(tags: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appDeleteMulti + tags)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Removed"
                } else if (httpResponse.statusCode == 204) {
                    result = "Document Removal Failed: No Content"
                } else if (httpResponse.statusCode == 406) {
                    result = "Document Removal Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "Document Removal Failed: Link Not Found"
                } else {
                    result = "Document Removal Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("DELETE-MULTI", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates an HTTP GET for view all documents. Sends the parsed XML to any controllers listening
    */
    func viewAllDocumentsOnServer() {
        var request = NSMutableURLRequest(URL: NSURL(string: appViewAll)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("VIEWALL", object: nil, userInfo: self.buildDocumentListFromXML(data))
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates a HTTP Get with document tags. Parses the result XML and notifies any listening view controllers
    */
    func queryLocalDocumentsOnServer(tags: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appQuery + tags)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                
                NSNotificationCenter.defaultCenter().postNotificationName("QUERY", object: nil, userInfo: self.buildDocumentListFromXML(data))
            }
            
        })
        
        task.resume()
    }
    
    
    /**
    Creates a HTTP Get with document tags. Parses the result XML and notifies any listening view controllers
    */
    func queryLocalDocumentsOnServerHTML(tags: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appQuery + tags)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("QUERY-HTML", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    
    /**
    returns a list of documents parsed from XML data
    */
    func buildDocumentListFromXML(data: NSData) -> Dictionary<Int, Document> {
        var docList: Dictionary<Int, Document> = Dictionary<Int, Document>()
        
        println("in here")
        var error: NSError?
        if let xml = AEXMLDocument(xmlData: data, error: &error) {
            
            println("parse")
            println(xml.xmlString)
            if let documents = xml.root["document"].all {
                for doc in documents {
                    
                    let id: Int = doc["id"].intValue
                    let score: String = doc["score"].stringValue
                    let name: String = doc["name"].stringValue
                    let text: String = doc["text"].stringValue
                    
                    let scoreF: Float = (score as NSString).floatValue
                    
                    var document: Document = Document(id: id, score: scoreF, name: name, text: text)
                    
                    for item in doc.children {
                        
                        if(item.name == "tag") {
                            document.addTag(item.value!)
                        }
                        
                        if(item.name == "link") {
                            document.addLink(item.value!)
                        }
                        
                    }
                    
                    docList[document.id] = document
                }
            }
            
        } else {
            println("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
        }
        
        return docList
    }
    
    //MARK: - Assignment 2
    
    /**
    Sends empty XML as GET, returns Response Code
    */
    func sdaResetRequest() {
        var request = NSMutableURLRequest(URL: NSURL(string: sdaReset)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "SDA Reset"
                } else if(httpResponse.statusCode == 204){
                    result = "SDA Reset Failed: No Content"
                } else if (httpResponse.statusCode == 406) {
                    result = "SDA Reset Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "SDA Reset Failed: Link Not Found"
                } else {
                    result = "SDA Reset Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("RESET", object: nil, userInfo: dictionary)
            }
        })
        
        task.resume()
    }
    
    /**
    Sends empty XML as GET, returns HTML list of sda's
    */
    func sdaListRequest() {
        var request = NSMutableURLRequest(URL: NSURL(string: sdaList)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("LIST", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Sends empty XML as GET, returns HTML list of page ranks
    */
    func sdaPageRankRequest() {
        var request = NSMutableURLRequest(URL: NSURL(string: sdaPageRank)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("PAGERANK", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Sends empty XML as GET, returns Response Code
    */
    func sdaBoostRequest() {
        var request = NSMutableURLRequest(URL: NSURL(string: sdaBoost)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "SDA Boosted"
                } else if(httpResponse.statusCode == 204){
                    result = "SDA Boost Failed: No Content"
                } else if (httpResponse.statusCode == 406) {
                    result = "SDA Boost Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "SDA Boost Failed: Link Not Found"
                } else {
                    result = "SDA Boost Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("BOOST", object: nil, userInfo: dictionary)
            }
        })
        
        task.resume()
    }
    
    /**
    Sends empty XML as GET, returns Response Code
    */
    func sdaNoBoostRequest() {
        var request = NSMutableURLRequest(URL: NSURL(string: sdaNoBoost)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "SDA Boost Reset"
                } else if(httpResponse.statusCode == 204){
                    result = "SDA Boost Reset Failed: No Content"
                } else if (httpResponse.statusCode == 406) {
                    result = "SDA Boost Reset Failed: Bad Request"
                } else if (httpResponse.statusCode == 404) {
                    result = "SDA Boost Reset Failed: Link Not Found"
                } else {
                    result = "SDA Boost Reset Failed: Internal Server Error"
                }
                
                var dictionary = Dictionary<String, String>()
                dictionary["message"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("NOBOOST", object: nil, userInfo: dictionary)
            }
        })
        
        task.resume()
    }
    
    /**
    Sends empty XML as GET with terms, returns HTML list of results
    */
    func sdaDistrubedSearchHTML(terms: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: sdaSearch + terms)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("SEARCH-HTML", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
    /**
    Creates a HTTP Get with document tags. Parses the result XML and notifies any listening view controllers
    */
    func sdaDistrubedSearchXML(terms: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appQuery + terms)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError? = error
            
            if(err != nil) {
                var dictionary = Dictionary<String, String>()
                dictionary["error"] = err!.localizedDescription
                NSNotificationCenter.defaultCenter().postNotificationName("NETWORK-ERROR", object: nil, userInfo: dictionary)
            } else {
                
                var nsData: NSData = data
                var dictionary: Dictionary<Int, Document> = Dictionary<Int, Document>()
                let bg_task = Async.background {
                    var dictionary = self.buildDocumentListFromXML(nsData)
                }
                
                bg_task.wait()
                
                NSNotificationCenter.defaultCenter().postNotificationName("SEARCH-XML", object: nil, userInfo: dictionary)
                
            }
            
        })
        
        task.resume()
    }
}
