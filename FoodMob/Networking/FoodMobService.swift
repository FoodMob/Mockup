//
//  FoodMobService.swift
//  FoodMob
//
//  Created by Jonathan Jemson on 2/5/16.
//  Copyright © 2016 Jonathan Jemson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 The actual FoodMob service data source.   Requires network access in order to function properly.
*/

public struct FoodMobService: FoodMobDataSource {
    
    private struct ServiceEndpoint : Endpoint {
        static var root: String {
            return "https://fm.fluf.me"
        }
    }

    public func login(emailAddress: String, password: String, completion: ((User?) -> ())? = nil) {
        guard validateEmailAddress(emailAddress) && validatePassword(password) else {
            completion?(nil)
            return
        }
        Alamofire.request(ServiceEndpoint.loginMethod, ServiceEndpoint.login, parameters: [UserField.emailAddress: emailAddress, UserField.password: password], encoding: .JSON).validate().responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    if let firstName = json[UserField.profile][UserField.firstName].string,
                        lastName = json[UserField.profile][UserField.lastName].string,
                        emailAddress = json[UserField.emailAddress].string, authToken = json[UserField.authToken].string {
                            let user = User(firstName: firstName, lastName: lastName, emailAddress: emailAddress, authToken: authToken)
                            completion?(user)
                    } else {
                        completion?(nil)
                    }
                }
            case .Failure(let error):
                print(error)
                completion?(nil)
            }
        }
    }

    @warn_unused_result
    public func register(firstName firstName: String, lastName: String, emailAddress: String, password: String, completion: ((Bool) -> ())? = nil) {
        guard validateName(firstName) &&
            validateName(lastName) &&
            validateEmailAddress(emailAddress) &&
            validatePassword(password)
            else {
                completion?(false)
                return
        }
        let parameters = [
            UserField.emailAddress : emailAddress,
            UserField.password : password,
            UserField.firstName : firstName,
            UserField.lastName : lastName
        ]
        Alamofire.request(ServiceEndpoint.registerMethod, ServiceEndpoint.register, parameters: parameters, encoding: .JSON).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    completion?(json["success"].boolValue)
                    print(json)
                }
            case .Failure(let error):
                print(error)
                completion?(false)
            }
        }
    }

    public func logout(user: User, completion: ((Bool) -> ())? = nil) {
        Alamofire.request(ServiceEndpoint.logoutMethod, ServiceEndpoint.logout, parameters: [UserField.emailAddress: user.emailAddress, UserField.authToken: user.authToken], encoding: .JSON).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    completion?(json["success"].boolValue)
                }
            case .Failure(let error):
                print(error)
                completion?(false)
            }
        }

        // We should probably log the user out of the local app anyway.
        user.eraseUser()
    }
    
    public func updateCategoriesForUser(user: User) {
        var likes = [String]()
        var dislikes = [String]()
        var restrictions = [String]()
        
        for (cat, pref) in user.categories {
            switch pref {
            case .Like:
                likes += [cat.rawValue]
            case .Dislike:
                dislikes += [cat.rawValue]
            case .Restriction:
                restrictions += [cat.rawValue]
            default:
                print("Ignoring pref \(cat.rawValue)")
            }
        }
        
        let foodProfile = [UserField.FoodProfile.likes: likes, UserField.FoodProfile.dislikes: dislikes, UserField.FoodProfile.restrictions : restrictions]
        
            Alamofire.request(ServiceEndpoint.updateFoodProfileMethod, ServiceEndpoint.foodProfile(user), parameters: [UserField.authToken: user.authToken, UserField.foodProfile: foodProfile], encoding: .JSON).validate().responseJSON { response in
            
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                }
            case .Failure(let error):
                print(error)
            }
            
        }
    }
    
    public func fetchCategoriesForUser(user: User, completion: ((Bool)->())? = nil) {
        Alamofire.request(ServiceEndpoint.getFoodProfileMethod, ServiceEndpoint.foodProfile(user), parameters: [UserField.authToken: user.authToken], encoding: .URL).validate().responseJSON { response in
            debugPrint(response.request)
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    let profile = json[UserField.foodProfile].dictionaryValue
                    var categories = [FoodCategory : Preference]()
                    if let likes = profile[UserField.FoodProfile.likes]?.arrayValue,
                        dislikes = profile[UserField.FoodProfile.dislikes]?.arrayValue,
                        restrictions = profile[UserField.FoodProfile.restrictions]?.arrayValue {
                        for like in likes {
                            if let cat = FoodCategory(rawValue: like.stringValue) {
                                categories[cat] = Preference.Like
                            }
                        }
                        for dislike in dislikes {
                            if let cat = FoodCategory(rawValue: dislike.stringValue) {
                                categories[cat] = Preference.Dislike
                            }
                        }
                        for restriction in restrictions {
                            if let coolCat = FoodCategory(rawValue: restriction.stringValue) {
                                categories[coolCat] = Preference.Restriction
                            }
                        }
                        user.categories = categories
                    }
                    completion?(json["success"].boolValue)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}