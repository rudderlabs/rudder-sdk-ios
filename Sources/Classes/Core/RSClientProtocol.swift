//
//  RSClientProtocol.swift
//  Rudder
//
//  Created by Pallab Maiti on 06/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public protocol RSClientProtocol: AnyObject {
    
    /// Given instance name.
    var instanceName: String { get }
    
    /// Configuration of RudderStack SDK.
    var configuration: Configuration { get }
    
    /// A UserDefaultsWorker instance.
    var userDefaultsWorker: UserDefaultsWorkerProtocol { get }
    
    /// StorageWorker instance.
    var storageWorker: StorageWorkerProtocol { get }
    
    /// SessionStorage instance.
    var sessionStorage: SessionStorageProtocol { get }
    
    /// Print logging information.
    var logger: Logger { get }
    
    /// Returns the RudderStack instance for the given name.
    ///
    /// - Parameter name: The name of the instance to get.
    /// - Returns: The instance by the name if exists, otherwise nil.
    func addPlugin(_ plugin: Plugin)
    
    /// Remove a Plugin instance.
    /// - Parameter plugin: The Plugin instance.
    func removePlugin(_ plugin: Plugin)
    
    /// Retrieve all Plugin instance list.
    ///
    /// - Returns: The list of all Plugins.
    func getAllPlugins() -> [Plugin]?
    
    /// Retrieve all destination Plugin instance list.
    ///
    /// - Returns: The list of Plugins if any.
    func getDestinationPlugins() -> [DestinationPlugin]?
    
    /// Retrieve all default Plugin instance list.
    ///
    /// - Returns: The list of default Plugins if any.
    func getDefaultPlugins() -> [Plugin]?
    
    /// Retrive a Plugin instance by instance type.
    /// - Parameter type: The Plugin instance type.
    /// - Returns: The instance of Plugin if any.
    func getPlugin<T: Plugin>(type: T.Type) -> T?
    
    /// Associate a handler to all the Plugin list.
    ///
    /// - Parameter handler: The closure which takes a Plugin as a parameter.
    func associatePlugins(_ handler: (Plugin) -> Void)
    
    /// Record user's activity.
    ///
    /// - Parameters:
    ///   - eventName: The name of the activity.
    ///   - properties: Extra data properties regarding the event, if any.
    ///   - option: Extra event options, if any.
    func track(_ eventName: String, properties: TrackProperties?, option: MessageOptionType?)
    
    /// Set current user's information
    ///
    /// - Parameters:
    ///   - userId: User's ID.
    ///   - traits: User's additional information, if any.
    ///   - option: Event level option, if any.
    func identify(_ userId: String, traits: IdentifyTraits?, option: MessageOptionType?)
    
    /// Track a screen with name, category.
    ///
    /// - Parameters:
    ///   - screenName: The name of the screen viewed by an user.
    ///   - category: The category or type of screen, if any.
    ///   - properties: Extra data properties regarding the screen call, if any.
    ///   - option: Extra screen event options, if any.
    func screen(_ screenName: String, category: String?, properties: ScreenProperties?, option: MessageOptionType?)
    
    /// Associate an user to a company or organization.
    ///
    /// - Parameters:
    ///   - groupId: The company's ID.
    ///   - traits: Extra information of the company, if any.
    ///   - option: Event level options, if any.
    func group(_ groupId: String, traits: GroupTraits?, option: MessageOptionType?)
    
    /// Associate the current user to a new identification.
    ///
    /// - Parameters:
    ///   - groupId: User's new ID.
    ///   - option: Event level options, if any.
    func alias(_ newId: String, option: MessageOptionType?)
}
