//
//  APIHandlerError.swift
//  process
//
//  Created by maxfierro on 7/20/22.
//


import Foundation


/** Errors for database schema specific failure scenarios. */
enum APIHandlerError: Error {
    
    /** Attempted to read from missing authenticated current user. */
    case noAuthenticatedUser(String)
    
    /** Username repeat count document missing form database. */
    case noUsernameRepeatDocument(String)
    
    /** Multiple items found for request designed to be single ended. */
    case ambiguousRequest(String)
    
    /** No items were found for request designed to be non-empty. */
    case emptyRequest(String)
    
    /** Failed to upload data to storage. */
    case dataUploadFailed(String)
}
