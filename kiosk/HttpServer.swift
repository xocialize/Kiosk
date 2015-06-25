//
//  HttpServer.swift
//  Swifter
//  Copyright (c) 2014 Damian Kołakowski. All rights reserved.
//

import Foundation

class HttpServer
{
    typealias Handler = HttpRequest -> HttpResponse
    
    var handlers: [(expression: NSRegularExpression, handler: Handler)] = []
    var acceptSocket: CInt = -1
    
    let matchingOptions = NSMatchingOptions(rawValue: 0)
    let expressionOptions = NSRegularExpressionOptions(rawValue: 0)
    
    subscript (path: String) -> Handler? {
        get {
            return nil
        }
        set ( newValue ) {
            do {
                let regex = try NSRegularExpression(pattern: path, options: expressionOptions)
                if let newHandler = newValue {
                    handlers.append(expression: regex, handler: newHandler)
                }
            } catch _ {
            }
        }
    }
        
    func routes() -> [String] { return handlers.map({ $0.0.pattern }) }
    
    func start(listenPort: in_port_t = 8080) throws {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        releaseAcceptSocket()
        do {
            let socket = try Socket.tcpForListen(listenPort)
            acceptSocket = socket
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                
                
                while let socket = Socket.acceptClientSocket(self.acceptSocket) {
                    
                    try dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        let parser = HttpParser()
                        while let request = parser.nextHttpRequest(socket) {
                            let keepAlive = parser.supportsKeepAlive(request.headers)
                            if let (expression, handler) = self.findHandler(request.url) {
                                let capturedUrlsGroups = self.captureExpressionGroups(expression, value: request.url)
                                let updatedRequest = HttpRequest(url: request.url, urlParams: request.urlParams, method: request.method, headers: request.headers, body: request.body, capturedUrlGroups: capturedUrlsGroups)
                                HttpServer.respond(socket, response: handler(updatedRequest), keepAlive: keepAlive)
                            } else {
                                HttpServer.respond(socket, response: HttpResponse.NotFound, keepAlive: keepAlive)
                            }
                            if !keepAlive { break }
                        }
                        Socket.release(socket)
                    })
                }
                
                
                
                
                self.releaseAcceptSocket()
            })
            return
        } catch var error1 as NSError {
            error = error1
        }
        throw error
    }
    
    func findHandler(url:String) -> (NSRegularExpression, Handler)? {
        return self.handlers.filter({
            $0.0.numberOfMatchesInString(url, options: self.matchingOptions, range: HttpServer.asciiRange(url)) > 0
        }).first
    }
    
    func captureExpressionGroups(expression: NSRegularExpression, value: String) -> [String] {
        var capturedGroups = [String]()
        if let result = expression.firstMatchInString(value, options: matchingOptions, range: HttpServer.asciiRange(value)) {
            let nsValue: NSString = value
            for var i = 1 ; i < result.numberOfRanges ; ++i {
                if let group = nsValue.substringWithRange(result.rangeAtIndex(i)).stringByRemovingPercentEncoding {
                    capturedGroups.append(group)
                }
            }
        }
        return capturedGroups
    }
    
    class func asciiRange(value: String) -> NSRange {
        return NSMakeRange(0, value.lengthOfBytesUsingEncoding(NSASCIIStringEncoding))
    }
    
    class func respond(socket: CInt, response: HttpResponse, keepAlive: Bool) {
        
        do {
            try Socket.writeUTF8(socket, string: "HTTP/1.1 \(response.statusCode()) \(response.reasonPhrase())\r\n")
        } catch _ {
        }
        
        if let body = response.body() {
        
            do {
                try Socket.writeASCII(socket, string: "Content-Length: \(body.length)\r\n")
            } catch _ {
            }
        
        } else {
        
            do {
                try Socket.writeASCII(socket, string: "Content-Length: 0\r\n")
            } catch _ {
            }
        
        }
        
        if keepAlive {
        
            do {
                try Socket.writeASCII(socket, string: "Connection: keep-alive\r\n")
            } catch _ {
            }
        
        }
        
        for (name, value) in response.headers() {
        
            do {
                try Socket.writeASCII(socket, string: "\(name): \(value)\r\n")
            } catch _ {
            }
        
        }
        
        do {
            try Socket.writeASCII(socket, string: "\r\n")
        } catch _ {
        }
        
        if let body = response.body() {
        
            do {
                try Socket.writeData(socket, data: body)
            } catch _ {
            }
        
        }
    }
    
    func stop() {
        releaseAcceptSocket()
    }
    
    func releaseAcceptSocket() {
        if ( acceptSocket != -1 ) {
            Socket.release(acceptSocket)
            acceptSocket = -1
        }
    }
}

