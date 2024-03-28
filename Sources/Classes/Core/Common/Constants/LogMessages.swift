//
//  LogMessages.swift
//  Rudder
//
//  Created by Pallab Maiti on 28/11/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum LogMessages {
    enum API {
        case flush
        case sourceConfig
        
        var description: String {
            switch self {
            case .flush:
                return "Aborting flush"
            case .sourceConfig:
                return "Server config download failed"
            }
        }
    }
    case optOut
    case optOutAndEventDrop
    case tokenNotEmpty
    case anonymousIdNotEmpty
    case advertisingIdNotEmpty
    case userOptOut(Bool)
    case sourceDisabled
    case userIdNotEmpty
    case newIdNotEmpty
    case groupIdNotEmpty
    case screenNameNotEmpty
    case eventNameNotEmpty
    case sourceConfigDownloadSuccess
    case eventsCleared
    case newSession
    case sessionCanNotStart
    case sessionIdLengthInvalid(Int)
    case failedJSONConversion(String)
    case sqlStatement(String)
    case eventInsertionSuccess
    case eventInsertionFailure
    case eventDeletionSuccess
    case eventDeletionFailure
    case countFetched
    case schemaCreationSuccess
    case schemaCreationFailure
    case statementNotPrepared(String)
    case customMessage(String)
    case retry(String, TimeInterval)
    case retryAborted(String, Int)
    case destinationDisabled
    case eventFiltered
    case storageMigrationFailed(StorageError)
    case storageMigrationSuccess
    case legacyDatabaseDoesNotExists
    case storageMigrationFailedToReadSourceConfig
    case failedToDeleteLegacyDatabase(String)
    case apiError(API, APIError)
    
    var description: String {
        switch self {
        case .optOut:
            return "User has been Opted out"
        case .optOutAndEventDrop:
            return "User has been Opted out, hence dropping the event"
        case .tokenNotEmpty:
            return "Token can not be empty"
        case .anonymousIdNotEmpty:
            return "AnonymousId can not be empty"
        case .advertisingIdNotEmpty:
            return "AdvertisingId can not be empty"
        case .userOptOut(let status):
            return "User has been Opted \(status ? "out" : "in")"
        case .sourceDisabled:
            return "Source is disabled in your dashboard, hence dropping the event"
        case .userIdNotEmpty:
            return "UserId can not be empty"
        case .newIdNotEmpty:
            return "newId can not be empty"
        case .groupIdNotEmpty:
            return "groupId can not be empty"
        case .screenNameNotEmpty:
            return "screenName can not be empty"
        case .eventNameNotEmpty:
            return "eventName can not be empty"
        case .sourceConfigDownloadSuccess:
            return "Source config download successful"
        case .eventsCleared:
            return "Clearing events from storage"
        case .newSession:
            return "New session is started"
        case .sessionCanNotStart:
            return "SDK is not yet initialised, hence manual session cannot be started"
        case .sessionIdLengthInvalid(let sessionId):
            return "Length of the sessionId(\(sessionId)) should be at least 10"
        case .failedJSONConversion(let errorDescription):
            return "Failed to convert to JSON. Error: \(errorDescription)"
        case .sqlStatement(let statement):
            return "SQL: \(statement)"
        case .statementNotPrepared(let errorDescription):
            return "Statement is not prepared. Reason: \(errorDescription)"
        case .eventInsertionSuccess:
            return "Event inserted"
        case .eventInsertionFailure:
            return "Event insertion error"
        case .eventDeletionSuccess:
            return "Events deleted"
        case .eventDeletionFailure:
            return "Event deletion error"
        case .countFetched:
            return "Count fetched"
        case .schemaCreationSuccess:
            return "Database schema created"
        case .schemaCreationFailure:
            return "Database schema creation error"
        case .customMessage(let message):
            return message
        case .retry(let message, let interval):
            return "Retrying \(message) in \(interval) seconds"
        case .retryAborted(let reason, let retryCount):
            return "Maximum(\(retryCount)) retry count achieved, hence \(reason) aborted"
        case .destinationDisabled:
            return "Destination is not enabled"
        case .eventFiltered:
            return "Message is filtered by Client-side event filtering"
        case .storageMigrationFailed(let error):
            return "Storage migration failed. Reason: \(error.description)"
        case .storageMigrationSuccess:
            return "Successfully migrated data from legacy storage and deleted the legacy database."
        case .legacyDatabaseDoesNotExists:
            return "Legacy database does not exists, hence no migration needed"
        case .storageMigrationFailedToReadSourceConfig:
            return "Legacy database exists, but failed to read legacy SourceConfig, so cannot migrate data, hence deleting the legacy database"
        case .failedToDeleteLegacyDatabase(let reason):
            return "Failed to delete legacy database due to \(reason)"
        case .apiError(let api, let error):
            switch error {
            case .httpError(let statusCode):
                return "\(api.description). Error code: \(statusCode)"
            case .networkError(let error):
                return "\(api.description). Error: \(error.localizedDescription)"
            case .noResponse:
                return "No server response"
            }
        }
    }
}
