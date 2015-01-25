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
    
    func createDocumentOnServer(name: String, text: String, tags: String, links: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appCreate)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let xmlTags: StringBuilder = StringBuilder()
        let xmlLinks: StringBuilder = StringBuilder()
        let tagsArray: [String] = SharedHelper.buildTagsArrayFromString(tags)
        let linksArray: [String] = SharedHelper.buildLinksArrayFromString(links)
        
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
        
        print("Data: ")
        println(data)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        //request.addValue("text/html", forHTTPHeaderField: "Accept")
     
        println(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
        
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
    
    func updateDocumentOnServer(id: String, tags: String, links: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appUpdate + id)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        let xmlTags: StringBuilder = StringBuilder()
        let xmlLinks: StringBuilder = StringBuilder()
        let tagsArray: [String] = SharedHelper.buildTagsArrayFromString(tags)
        let linksArray: [String] = SharedHelper.buildLinksArrayFromString(links)
        
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
        //request.addValue("text/html", forHTTPHeaderField: "Accept")
        
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
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Update"
                } else if(httpResponse.statusCode == 204){
                    result = "Document Update Failed: Document Not Found"
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
    
    func deleteDocumentOnServer(id: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appDelete + id)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "DELETE"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        //request.HTTPBody = data
        //request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //request.addValue(length, forHTTPHeaderField: "Content-Length")
        //request.addValue("text/html", forHTTPHeaderField: "Accept")
        
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
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Removed"
                } else if (httpResponse.statusCode == 204) {
                    result = "Document Removal Failed: No Content"
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
                NSNotificationCenter.defaultCenter().postNotificationName("VIEW", object: nil, userInfo: dictionary)
            }

        })
        
        task.resume()
    }
    
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
                
                // TODO: Parse XML to document object
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data
                NSNotificationCenter.defaultCenter().postNotificationName("VIEW-XML", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
    
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
        //request.addValue("text/html", forHTTPHeaderField: "Accept")
        
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
            } else if let httpResponse: NSHTTPURLResponse! = response as? NSHTTPURLResponse {
                
                var result: String! = ""
                
                if(httpResponse.statusCode == 200) {
                    result = "Document Removed"
                } else if (httpResponse.statusCode == 204) {
                    result = "Document Removal Failed: No Content"
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
                
                let xml = SWXMLHash.parse(data)
                var docList: Dictionary<Int, Document> = Dictionary<Int, Document>()
                
                for elem in xml["documents"]["document"] {
                    
                    let id: Int = elem["id"].element!.text!.toInt()!
                    let name: String = elem["name"].element!.text!
                    let text: String = elem["text"].element!.text!
                    
                    var document: Document = Document(id: id, score: 0, name: name, text: text)
                    
                    for tag in elem["tags"]["tag"] {
                        
                        document.addTag(tag.element!.text!)
                        
                    }

                    for link in elem["links"]["link"] {
                        
                        document.addLink(link.element!.text!)
                        
                    }
                    
                    docList[document.id] = document
                    /*let doc: XMLIndexer = elem["document"]
                    
                    let id: Int = doc["id"].element!.text!.toInt()!
                    let score: Int = doc["score"].element!.text!.toInt()!
                    let name: String = doc["name"].element!.text!
                    let text: String = doc["text"].element!.text!
                    
                    var document: Document = Document(id: id, score: score, name: name, text: text)
                    
                    let tags: XMLIndexer = elem["tags"]
                    for tag in tags {
                        
                        document.addTag(tag["tag"].element!.text!)
                        
                    }
                    
                    let links: XMLIndexer = elem["links"]
                    for link in links {
                        
                        document.addLink(link["link"].element!.text!)
                        
                    }*/
                }
                
                /*
                var dictionary = Dictionary<String, NSData>()
                dictionary["data"] = data*/
                NSNotificationCenter.defaultCenter().postNotificationName("VIEWALL", object: nil, userInfo: docList)
            }
  
        })
        
        task.resume()
    }
    
    func searchDocumentsOnServer(tags: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: appSearch + tags)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let data : NSData = ("").dataUsingEncoding(NSUTF8StringEncoding)!;
        let length: NSString = NSString(format: "%d", data.length)
        
        var err: NSError?
        request.HTTPBody = data
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(length, forHTTPHeaderField: "Content-Length")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
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
                NSNotificationCenter.defaultCenter().postNotificationName("SEARCH", object: nil, userInfo: dictionary)
            }
            
        })
        
        task.resume()
    }
}
