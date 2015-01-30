//
//  Document.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-24.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class Document: NSObject {
    
    var id: Int!
    var score: Int!
    var name: String!
    var text: String!
    var tags: [String]!
    var links: [String]!
    
    /**
    Constructor for document object
    */
    init(id: Int, score: Int, name: String, text: String, tags: [String], links: [String]) {
        self.id = id
        self.score = score
        self.name = name
        self.text = text
        self.tags = tags
        self.links = links
    }
    
    /**
    Constructor for document object with empty arrays
    */
    init(id: Int, score: Int, name: String, text: String) {
        self.id = id
        self.score = score
        self.name = name
        self.text = text
        self.tags = []
        self.links = []
    }
    
    /**
    Adds a tag to a tag array
    */
    func addTag(tag: String) {
        tags.append(tag)
    }
    
    /**
    Removes a tag from a tag array
    */
    func removeTag(tag: String) {
        var count: Int = 0
        
        for s: String in tags {
            if(s == tag) {
                tags.removeAtIndex(count)
            }
            count++
        }
    }
    
    /**
    Adds a link to a link array
    */
    func addLink(link: String) {
        links.append(link)
    }
    
    /**
    Removes a link from a link array
    */
    func removeLink(link: String) {
        var count: Int = 0
        
        for s: String in links {
            if(s == link) {
                links.removeAtIndex(count)
            }
            count++
        }
    }
    
}
