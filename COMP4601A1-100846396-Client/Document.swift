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
    
    init(id: Int, score: Int, name: String, text: String, tags: [String], links: [String]) {
        self.id = id
        self.score = score
        self.name = name
        self.text = text
        self.tags = tags
        self.links = links
    }
    
    init(id: Int, score: Int, name: String, text: String) {
        self.id = id
        self.score = score
        self.name = name
        self.text = text
        self.tags = []
        self.links = []
    }
    
    func addTag(tag: String) {
        tags.append(tag)
    }
    
    func removeTag(tag: String) {
        var count: Int = 0
        
        for s: String in tags {
            if(s == tag) {
                tags.removeAtIndex(count)
            }
            count++
        }
    }
    
    func addLink(link: String) {
        links.append(link)
    }
    
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
