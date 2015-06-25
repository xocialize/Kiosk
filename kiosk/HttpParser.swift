//
//  HttpParser.swift
//  Swifter
//  Copyright (c) 2014 Damian Kołakowski. All rights reserved.
//

import Foundation

class HttpParser {
    
    func err(reason: String) -> NSError {
        return NSError(domain: "HttpParser", code: 0, userInfo: [NSLocalizedDescriptionKey : reason])
    }
    
    func nextHttpRequest(socket: CInt) throws -> HttpRequest {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        do {
            let statusLine = try nextLine(socket)
            let statusTokens = split(statusLine.characters, isSeparator: { $0 == " " }).map { String($0) }
            //println(statusTokens)
            if ( statusTokens.count < 3 ) {
                # /* TODO: Finish migration: rewrite code to move the next statement out of enclosing do/catch */
                throw err("Invalid status line: \(statusLine)")
            }
            let method = statusTokens[0]
            let path = statusTokens[1]
            let urlParams = extractUrlParams(path)
            // TODO extract query parameters
            do {
                let headers = try nextHeaders(socket)
                // TODO detect content-type and handle:
                // 'application/x-www-form-urlencoded' -> Dictionary
                // 'multipart' -> Dictionary
                if let contentSize = Int(headers["content-length"]?) {
                    let body: String?
                    do {
                        body = try nextBody(socket, size: contentSize)
                    } catch var error1 as NSError {
                        error = error1
                        body = nil
                    }
                    return HttpRequest(url: path, urlParams: urlParams, method: method, headers: headers, body: body, capturedUrlGroups: [])
                }
                return HttpRequest(url: path, urlParams: urlParams, method: method, headers: headers, body: nil, capturedUrlGroups: [])
            } catch var error1 as NSError {
                error = error1
            }
        } catch var error1 as NSError {
            error = error1
        }
        throw error
    }
    
    private func extractUrlParams(url: String) -> [(String, String)] {
        if let query = split(url.characters, isSeparator: { $0 == "?" }).map { String($0) }.last {
            return split(query.characters, isSeparator: { $0 == "&" }).map { String($0) }.map({ (param:String) -> (String, String) in
                let tokens = split(param.characters, isSeparator: { $0 == "=" }).map { String($0) }
                if tokens.count >= 2 {
                    let key = tokens[0].stringByRemovingPercentEncoding
                    let value = tokens[1].stringByRemovingPercentEncoding
                    if key != nil && value != nil { return (key!, value!) }
                }
                return ("","")
            })
        }
        return []
    }
    
    private func nextBody(socket: CInt, size: Int ) throws -> String {
        var body = ""
        var counter = 0;
        while ( counter < size ) {
            let c = nextInt8(socket)
            if ( c < 0 ) {
                throw err("IO error while reading body")
            }
            body.append(UnicodeScalar(c))
            counter++;
        }
        return body
    }
    
    private func nextHeaders(socket: CInt) throws -> Dictionary<String, String> {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        var headers = Dictionary<String, String>()
        while let headerLine = nextLine(socket) {
            if ( headerLine.isEmpty ) {
                return headers
            }
            let headerTokens = split(headerLine.characters, isSeparator: { $0 == ":" }).map { String($0) }
            if ( headerTokens.count >= 2 ) {
                // RFC 2616 - "Hypertext Transfer Protocol -- HTTP/1.1", paragraph 4.2, "Message Headers":
                // "Each header field consists of a name followed by a colon (":") and the field value. Field names are case-insensitive."
                // We can keep lower case version.
                let headerName = headerTokens[0].lowercaseString
                let headerValue = headerTokens[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if ( !headerName.isEmpty && !headerValue.isEmpty ) {
                    headers.updateValue(headerValue, forKey: headerName)
                }
            }
        }
        throw error
    }

    private func nextInt8(socket: CInt) -> Int {
        var buffer = [UInt8](count: 1, repeatedValue: 0);
        let next = recv(socket as Int32, &buffer, Int(buffer.count), 0)
        if next <= 0 { return next }
        return Int(buffer[0])
    }
    
    private func nextLine(socket: CInt) throws -> String {
        var characters: String = ""
        var n = 0
        repeat {
            n = nextInt8(socket)
            if ( n > 13 /* CR */ ) { characters.append(Character(UnicodeScalar(n))) }
        } while ( n > 0 && n != 10 /* NL */)
        if ( n == -1 && characters.isEmpty ) {
            throw Socket.lastErr("recv(...) failed.")
        }
        return characters
    }
    
    func supportsKeepAlive(headers: Dictionary<String, String>) -> Bool {
        if let value = headers["connection"] {
            return "keep-alive" == value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        }
        return false
    }
}
