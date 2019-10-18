//
//  RudderTraits.swift
//  RudderSample
//
//  Created by Arnab Pal on 12/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

open class RudderTraits: NSObject, Encodable {
    var anonymousId: String
    var address: TraitsAddress? = nil
    var age: Int? = nil
    var birthday: String? = nil
    var company: TraitsCompany? = nil
    var createdAt: String? = nil
    var desc: String? = nil
    var email: String? = nil
    var firstName: String? = nil
    var gender: String? = nil
    var id: String? = nil
    var lastName: String? = nil
    var name: String? = nil
    var phone: String? = nil
    var title: String? = nil
    var userName: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case anonymousId =  "anonymousId"
        case address = "address"
        case age = "age"
        case birthday = "birthday"
        case company = "company"
        case createdAt = "createdat"
        case desc = "description"
        case email = "email"
        case firstName = "firstname"
        case gender = "gender"
        case id = "id"
        case lastName = "lastname"
        case name = "name"
        case phone = "phone"
        case title = "title"
        case userName = "username"
    }
    
    init(anonymousId: String) {
        self.anonymousId = anonymousId
    }
    
    init(address: TraitsAddress, age: Int, birthday: String, company: TraitsCompany, createdAt: String, description: String, email: String, firstName: String, gender: String, id: String, lastName: String, name: String, phone: String, title: String, userName: String) {
        self.anonymousId = RudderElementCache.getCachedContext().deviceInfo.id
        self.address = address
        self.age = age
        self.birthday = birthday
        self.company = company
        self.createdAt = createdAt
        self.desc = description
        self.email = email
        self.firstName = firstName
        self.gender = gender
        self.id = id
        self.lastName = lastName
        self.name = name
        self.phone = phone
        self.title = title
        self.userName = userName
    }
}
