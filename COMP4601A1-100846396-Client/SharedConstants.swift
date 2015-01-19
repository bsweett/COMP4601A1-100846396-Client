//
//  SharedConstants.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

//current active server
var appCurrentServer: String = appServerLocal

//Server addresses
let appServerLocal: String = "http://localhost:8080"
let appServerBenHome: String = "http://localhost:8080"
let appServerBraydenHome: String = "http://localhost:8080"

//Server REST Calls

//create - POST
let appCreate: String = appCurrentServer+"/sda/"

//update - PUT {id}
let appUpdate: String = appCurrentServer+"/sda/"

//view - GET {id}
let appView: String = appCurrentServer+"/sda/"
let appSearch: String = appCurrentServer+"/sda/search/"

//delete - DELETE {id} and deleteMulti - GET {id}
let appDelete: String = appCurrentServer+"/sda/"
let appDeleteMulti: String = appCurrentServer+"/sda/delete/"

//viewAll - GET {id{
let appViewAll: String = appCurrentServer+"/sda/documents/"