//
//  RudderTraitsBuilder.swift
//  RudderSample
//
//  Created by Arnab Pal on 23/07/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

public class RudderTraitsBuilder : NSObject {
    private var city: String = ""
    func setCity(city: String) -> RudderTraitsBuilder {
        self.city = city
        return self
    }
    
    private var country: String = ""
    func setCountry(country: String) -> RudderTraitsBuilder {
        self.country = country
        return self
    }
    
    private var postalCode: String = ""
    func setPostalCode(postalCode: String) -> RudderTraitsBuilder {
        self.postalCode = postalCode
        return self
    }
    
    private var state: String = ""
    func setState(state: String) -> RudderTraitsBuilder {
        self.state = state
        return self
    }
    
    private var street: String = ""
    func setStreet(street: String) -> RudderTraitsBuilder {
        self.street = street
        return self
    }
    
    private var age: Int = 0
    func setAge(age: Int) -> RudderTraitsBuilder {
        self.age = age
        return self
    }
    
    private var birthday: String = ""
    func setBirthday(birthday: String) -> RudderTraitsBuilder {
        self.birthday = birthday
        return self
    }
    
    private var companyName: String = ""
    func setCompanyName(companyName: String) -> RudderTraitsBuilder {
        self.companyName = companyName
        return self
    }
    
    private var companyId: String = ""
    func setCompanyId(companyId: String) -> RudderTraitsBuilder {
        self.companyId = companyId
        return self
    }
    
    private var industry: String = ""
    func setIndustry(industry: String) -> RudderTraitsBuilder {
        self.industry = industry
        return self
    }
    
    private var createdAt: String = ""
    func setCreatedAt(createdAt: String) -> RudderTraitsBuilder {
        self.createdAt = createdAt
        return self
    }
    
    private var desc: String = ""
    func setDescription(description: String) -> RudderTraitsBuilder {
        self.desc = description
        return self
    }
    
    private var email: String = ""
    func setEmail(email: String) -> RudderTraitsBuilder {
        self.email = email
        return self
    }
    
    private var firstName: String = ""
    func setFirstName(firstName: String) -> RudderTraitsBuilder {
        self.firstName = firstName
        return self
    }
    
    private var gender: String = ""
    func setGender(gender: String) -> RudderTraitsBuilder {
        self.gender = gender
        return self
    }
    
    private var id: String = ""
    func setId(id: String) -> RudderTraitsBuilder {
        self.id = id
        return self
    }
    
    private var lastName: String = ""
    func setLastName(lastName: String) -> RudderTraitsBuilder {
        self.lastName = lastName
        return self
    }
    
    private var name: String = ""
    func setName(name: String) -> RudderTraitsBuilder {
        self.name = name
        return self
    }
    
    private var phone: String = ""
    func setPhone(phone: String) -> RudderTraitsBuilder {
        self.phone = phone
        return self
    }
    
    private var title: String = ""
    func setTitle(title: String) -> RudderTraitsBuilder {
        self.title = title
        return self
    }
    
    private var userName: String = ""
    func setUserName(userName: String) -> RudderTraitsBuilder {
        self.userName = userName
        return self
    }
    
    func build() -> RudderTraits {
        return RudderTraits(address: TraitsAddress(city: self.city, country: self.country, postalCode: self.postalCode, state: self.state, street: self.street), age: self.age, birthday: self.birthday, company: TraitsCompany(name: self.companyName, id: self.companyId, industry: self.industry), createdAt: self.createdAt, description: self.desc, email: self.email, firstName: self.firstName, gender: self.gender, id: self.id, lastName: self.lastName, name: self.name, phone: self.phone, title: self.title, userName: self.userName)
    }
}
