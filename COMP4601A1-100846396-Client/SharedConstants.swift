//
//  SharedConstants.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

//current active server
var appCurrentServer: String = appServerLocal + restBase

//Server addresses
let appServerLocal: String = "http://localhost:8080"
let appServerBenHome: String = "http://192.168.1.101:8080"
let appServerBraydenHome: String = "http://localhost:8080"

//Server REST Calls
let restBase: String = "/COMP4601SDA/rest/sda/"

//create - POST
let appCreate: String = appCurrentServer

//update - PUT {id}
let appUpdate: String = appCurrentServer

//view - GET {id}/{tags}
let appView: String = appCurrentServer
let appSearch: String = appCurrentServer + "search/"

//delete - DELETE {id} and deleteMulti - GET {tags}
let appDelete: String = appCurrentServer
let appDeleteMulti: String = appCurrentServer + "delete/"

//viewAll - GET {id}
let appViewAll: String = appCurrentServer + "documents/"