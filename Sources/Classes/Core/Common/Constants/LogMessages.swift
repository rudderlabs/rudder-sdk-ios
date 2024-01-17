//
//  LogMessages.swift
//  Rudder
//
//  Created by Pallab Maiti on 28/11/23.
//  Copyright © 2023 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

enum LogMessages {
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
    case flushAbortedWithStatusCode(Int)
    case flushAbortedWithErrorDescription(String)
    case sourceConfigDownloadFailedWithStatusCode(Int)
    case sourceConfigDownloadFailedWithErrorDescription(String)
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
    case noResponse
    
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
        case .flushAbortedWithStatusCode(let statusCode):
            return "Aborting flush. Error code: \(statusCode)"
        case .flushAbortedWithErrorDescription(let errorDescription):
            return "Aborting flush. Error: \(errorDescription)"
        case .sourceConfigDownloadFailedWithStatusCode(let statusCode):
            return "Server config download failed. Error code: \(statusCode)"
        case .sourceConfigDownloadFailedWithErrorDescription(let errorDescription):
            return "Server config download failed. Error: \(errorDescription)"
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
            return "Statement is not prepared, reason: \(errorDescription)"
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
        case .noResponse:
            return "No server response"
        }
    }
}
