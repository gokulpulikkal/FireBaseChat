//
//  EncryptionHelper.swift
//  FireStoreDemo
//
//  Created by Gokul P on 16/02/24.
//  Copyright © 2024 Gokul. All rights reserved.
//

import Foundation
import CryptoKit

final public class EncryptionHelper {
    public static let shared = EncryptionHelper()
    
    var ciphersuite = HPKE.Ciphersuite.P384_SHA384_AES_GCM_256
    let protocolInfo = "CryptoKit Playgrounds Putting It Together".data(using: .utf8)!
    
    private init() {
        
    }
    
    public func checkKeys(_ key: Data?) {
        guard let recipientPublicKey = key, let publicKey = try? P384.KeyAgreement.PublicKey(rawRepresentation: recipientPublicKey) else { return }
        guard let senderPublicKeyBytes = UserDefaults.standard.value(forKey: BaseViewController.publicKey) as? Data, let senderPublicKey = try? P384.KeyAgreement.PublicKey(rawRepresentation: senderPublicKeyBytes) else { return }
    }
    
    public func encryptData(message: String, recipientPublicKey: Data?) -> (cipherText: Data?, encapsulatedKey: Data?) {
        guard let recipientPublicKey = recipientPublicKey, let publicKey = try? P384.KeyAgreement.PublicKey(rawRepresentation: recipientPublicKey) else { return (nil, nil) }
        guard let senderPublicKeyBytes = UserDefaults.standard.value(forKey: BaseViewController.publicKey) as? Data, let senderPublicKey = try? P384.KeyAgreement.PublicKey(rawRepresentation: senderPublicKeyBytes) else { return (nil, nil) }
        
        var hpkeSender = try? HPKE.Sender(recipientKey: publicKey, ciphersuite: ciphersuite, info: protocolInfo)
        if let messageData = message.data(using: .utf8) {
            let cipherText = try? hpkeSender?.seal(messageData)
            let encapsulatedKey = hpkeSender?.encapsulatedKey
            return (cipherText, encapsulatedKey)
        }
        return (nil, nil)
    }
    
    public func decryptData(cipherText: Data?, encapsulatedKey: Data?) -> String? {
        guard let cipherText = cipherText, let privateKeyRaw = UserDefaults.standard.value(forKey: BaseViewController.privateKey) as? Data, let privateKey = try? P384.KeyAgreement.PrivateKey(rawRepresentation: privateKeyRaw), let encapsulatedKey = encapsulatedKey else { return nil }
        var hpkeRecipient = try! HPKE.Recipient(privateKey: privateKey,
                                                ciphersuite: ciphersuite,
                                                info: protocolInfo,
                                                encapsulatedKey: encapsulatedKey)
        if let message = try? hpkeRecipient.open(cipherText){
            let str = String(decoding: message, as: UTF8.self)
            return str
        }
        return nil
    }
}
