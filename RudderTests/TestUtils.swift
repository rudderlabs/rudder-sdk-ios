//
//  TestUtils.swift
//  RudderTests
//
//  Created by Pallab Maiti on 10/02/23.
//

import Foundation

internal final class TestUtils {
    
    static let shared = TestUtils()
    
    func getPath(forResource: String, ofType: String) -> String {
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: forResource, ofType: ofType) {
            return path
        } else {
            fatalError("\(forResource).\(ofType) not present in test bundle.")
        }
    }
    
    func getJSONString(forResource: String, ofType: String) -> String {
        let path = getPath(forResource: forResource, ofType: ofType)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            let data1 = try JSONSerialization.data(withJSONObject: jsonResult, options: .prettyPrinted)
            if let convertedString = String(data: data1, encoding: .utf8) {
                return convertedString
            } else {
                fatalError("Can not parse or invalid JSON.")
            }
        } catch {
            fatalError("Can not parse or invalid JSON.")
        }
    }
    
    func convertToDictionary(text: String) -> [String: String]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertToJSONString(arrayObject: NSMutableArray) -> String? {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
            if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                return jsonString as String
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
