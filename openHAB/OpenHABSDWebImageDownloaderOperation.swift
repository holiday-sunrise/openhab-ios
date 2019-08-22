//
//  OpenHABSDWebImageDownloaderOperation.swift
//  openHAB
//
//  Created by David O'Neill on 06/03/19.
//  Copyright (c) 2019 David O'Neill. All rights reserved.
//

import SDWebImage

class OpenHABSDWebImageDownloaderOperation: SDWebImageDownloaderOperation {
    override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
<<<<<<< HEAD
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            let dns = challenge.protectionSpace.distinguishedNames
            if dns != nil {
                let identity = NetworkConnection.clientCertificateManager.evaluateTrust(distinguishedNames: dns!)
                if identity != nil {
                    let credential = URLCredential.init(identity: identity!, certificates: nil, persistence: URLCredential.Persistence.forSession)
                    let disposition = URLSession.AuthChallengeDisposition.useCredential
                    completionHandler(disposition, credential)
                    return
                }
            }
            let disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
            completionHandler(disposition, nil)
            return
        }

        // Not a client certificate request to run the default handler
        super.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
=======
        let policy = AFRememberingSecurityPolicy()
        let result = policy.handleAuthenticationChallenge(challenge: challenge)
	switch result.0 {
	case .useCredential:
	    completionHandler(result.0, result.1)
	default:
	    // Not a client certificate request to run the default handler
	    super.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
	}
>>>>>>> master
    }
}
