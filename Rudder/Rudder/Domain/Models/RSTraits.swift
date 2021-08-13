//
//  RSTraits.swift
//  Rudder
//
//  Created by Desu Sai Venkat on 12/08/21.
//

import Foundation

class RSTraits  {
    
    var anonymousId: String?
    var address: [String : Any]?
    var age: String?
    var birthday: String?
    var company: [String : Any]?
    var createdAt: String?
    var traitsDescription: String?
    var email: String?
    var firstName: String?
    var gender: String?
    var userId: String?
    var lastName: String?
    var name: String?
    var phone: String?
    var title: String?
    var userName: String?
    var extras: [String : Any] = [:]
    
    init()
    {
        
    }
    
    init(anonymousId: String) {
        self.anonymousId = anonymousId
    }
    
    func initWithDict(dict:[String : Any]) -> RSTraits
    {
        self.extras = extras.merging(dict) {$1}
        return self
    }
    
    func getId() -> String?
    {
        return self.userId
    }
    
    func getExtras() -> [String : Any]
    {
        return self.extras
    }
    
    func putAddress(address: [String:Any]) -> RSTraits
    {
        self.address = address
        return self
    }
    
    func putAge(age: String) -> RSTraits {
        self.age = age
        return self
    }
    
    func putBirthdayString(birthday:String) -> RSTraits
    {
        self.birthday = birthday
        return self
    }
    
    func putBirthday(birthday: Date) -> RSTraits
    {
        self.birthday = RSUtils.getDateString(date: birthday)
        return self
    }
    
    func putCompany(company:[String:Any]) -> RSTraits
    {
        self.company = company
        return self
    }
    
    func putCreatedAt(createdAt:String) -> RSTraits
    {
        self.createdAt = createdAt
        return self
    }
    
    func putDescription(description:String) -> RSTraits
    {
        self.traitsDescription = description
        return self
    }
    
    func putEmail(email:String) -> RSTraits
    {
        self.email = email
        return self
    }
    
    func putFirstName(firstName:String) -> RSTraits
    {
        self.firstName = firstName
        return self
    }
    
    func putGender(gender:String) -> RSTraits
    {
        self.gender = gender
        return self
    }
    
    func putId(userId:String) -> RSTraits
    {
        self.userId = userId
        return self
    }
    
    func putLastName(lastName:String) -> RSTraits
    {
        self.lastName = lastName
        return self
    }
    
    func putName(name:String) -> RSTraits
    {
        self.name = name
        return self
    }
    
    func putPhone(phone:String) -> RSTraits
    {
        self.phone = phone
        return self
    }
    
    func putTitle(title:String) -> RSTraits
    {
        self.title = title
        return self
    }
    
    func putUserName(userName:String) -> RSTraits {
        self.userName = userName
        return self
    }
    
    func put(key:String, value:Any?) -> RSTraits
    {
        if(value != nil)
        {
            self.extras[key] = value
        }
        return self
    }
    
    func dict () -> [String : Any]
    {
        var tempDict:[String:Any] = [:]
        if (anonymousId != nil) {
            tempDict["anonymousId"] = anonymousId
        }
        if (address != nil) {
            tempDict["address"] = address
            
        }
        if (age != nil) {
            tempDict["age"] = age
        }
        if (birthday != nil) {
            tempDict["birthday"] = birthday
        }
        if (company != nil) {
            tempDict["company"] = company
        }
        if (createdAt != nil) {
            tempDict["createdAt"] = createdAt
        }
        if (traitsDescription != nil) {
            tempDict["description"] = traitsDescription
        }
        if (email != nil) {
            tempDict["email"] = email
        }
        if (firstName != nil) {
            tempDict["firstname"] = firstName
            
        }
        if (gender != nil) {
            tempDict["gender"] = gender
            
        }
        if (userId != nil) {
            tempDict["userId"] = userId
            
        }
        if (lastName != nil) {
            tempDict["lastname"] = lastName
            
        }
        if (name != nil) {
            tempDict["name"] = name
            
        }
        if (phone != nil) {
            tempDict["phone"] = phone
            
        }
        if (title != nil) {
            tempDict["title"] = title
            
        }
        if (userName != nil) {
            tempDict["userName"] = userName
            
        }
        tempDict = tempDict.merging(extras) {$1}
        return tempDict
    }
    
}












