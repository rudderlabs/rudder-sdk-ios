//
//  PagePropertyBuilder.swift
//  RudderSdkCore
//
//  Created by Arnab Pal on 11/10/19.
//  Copyright © 2019 Arnab Pal. All rights reserved.
//

import Foundation

public class PagePropertyBuilder: NSObject {
    private var title: String? = nil
    
    public func withTitle(title: String) -> PagePropertyBuilder {
        self.title = title
        return self
    }
    
    private var url: String? = nil
    
    public func withUrl(url: String) -> PagePropertyBuilder {
        self.url = url
        return self
    }
    
    private var path: String? = nil
    
    public func withPath(path: String) -> PagePropertyBuilder {
        self.path = path
        return self
    }
    
    private var referrer: String? = nil
    
    public func withReferrer(referrer: String) -> PagePropertyBuilder {
        self.referrer = referrer
        return self
    }
    
    private var search: String? = nil
    
    public func withSearch(search: String) -> PagePropertyBuilder {
        self.search = search
        return self
    }
    
    private var keywords: String? = nil
    
    public func withKeywords(keywords: String) -> PagePropertyBuilder {
        self.keywords = keywords
        return self
    }
    
    public func build() -> Dictionary<String, NSObject>? {
        if (self.url == nil || self.url!.isEmpty) {
            RudderLogger.logError(message: "url can not be nil or blank")
            return nil
        }
        
        var property: Dictionary<String, NSObject> = Dictionary()
        property["title"] = self.title as NSObject?
        property["url"] = self.url as NSObject?
        property["path"] = self.path as NSObject?
        property["referrer"] = self.referrer as NSObject?
        property["search"] = self.search as NSObject?
        property["keywords"] = self.keywords as NSObject?
        
        return property
    }
}
