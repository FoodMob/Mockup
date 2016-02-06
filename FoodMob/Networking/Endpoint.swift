//
//  Endpoint.swift
//  FoodMob
//
//  Created by Jonathan Jemson on 2/5/16.
//  Copyright © 2016 Jonathan Jemson. All rights reserved.
//

import Foundation

/**
 Encapsulates an endpoint for a FoodMob service provider.
 A protocol extension provides the rest of the routes.
 */
public protocol Endpoint {
    /**
     The root of the application.  For example: foodmob.me/api
     */
    static var root: String { get }
}


public extension Endpoint {
    static var login: String {
        return "\(self.root)/login"
    }
    static var register: String {
        return "\(self.root)/register"
    }
}