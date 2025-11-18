import Foundation
import CryptoKit

/// Service for implementing SSL certificate pinning to prevent man-in-the-middle attacks
final class SSLPinningService: NSObject {
    static let shared = SSLPinningService()

    private override init() {
        super.init()
    }

    // MARK: - Certificate Pinning Configuration

    /// Pinned certificate hashes (SHA-256) for trusted domains
    /// TODO: Replace with actual certificate hashes from your backend
    private let pinnedCertificates: [String: Set<String>] = [
        "firestore.googleapis.com": [
            // Add Firebase certificate SHA-256 hashes here
            // Example: "ABC123...XYZ"
        ],
        "firebasestorage.googleapis.com": [
            // Add Firebase Storage certificate SHA-256 hashes here
        ],
        "nominatim.openstreetmap.org": [
            // Add OpenStreetMap certificate SHA-256 hashes here
        ],
        "api.geonames.org": [
            // Add GeoNames certificate SHA-256 hashes here
        ]
    ]

    /// Public key pinning (alternative to certificate pinning)
    /// Public keys are more stable than certificates
    private let pinnedPublicKeys: [String: Set<String>] = [
        // Add public key hashes here if using public key pinning
    ]

    // MARK: - URLSession with Pinning

    /// Creates a URLSession with SSL pinning configured
    func createPinnedURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
    }

    // MARK: - Certificate Validation

    /// Validates server trust against pinned certificates
    func validateServerTrust(
        _ serverTrust: SecTrust,
        forHost host: String
    ) throws {
        // If no pins configured for this host, allow the connection
        // In production, you might want to fail closed instead
        guard let pinned = pinnedCertificates[host], !pinned.isEmpty else {
            #if DEBUG
            print("⚠️ No certificate pins configured for \(host)")
            return
            #else
            throw SSLPinningError.noPinsConfigured(host)
            #endif
        }

        // Get certificates from server
        guard let serverCertificates = getServerCertificates(from: serverTrust) else {
            throw SSLPinningError.noCertificatesFound
        }

        // Check if any server certificate matches our pins
        for certificate in serverCertificates {
            let certificateHash = sha256Hash(of: certificate)

            if pinned.contains(certificateHash) {
                return // Valid certificate found
            }
        }

        // No matching certificate found
        throw SSLPinningError.certificateMismatch
    }

    /// Validates server trust against pinned public keys
    func validateServerTrustWithPublicKeys(
        _ serverTrust: SecTrust,
        forHost host: String
    ) throws {
        guard let pinned = pinnedPublicKeys[host], !pinned.isEmpty else {
            #if DEBUG
            print("⚠️ No public key pins configured for \(host)")
            return
            #else
            throw SSLPinningError.noPinsConfigured(host)
            #endif
        }

        // Get public keys from server
        guard let serverPublicKeys = getServerPublicKeys(from: serverTrust) else {
            throw SSLPinningError.noPublicKeysFound
        }

        // Check if any server public key matches our pins
        for publicKey in serverPublicKeys {
            let publicKeyHash = sha256Hash(of: publicKey)

            if pinned.contains(publicKeyHash) {
                return // Valid public key found
            }
        }

        throw SSLPinningError.publicKeyMismatch
    }

    // MARK: - Helper Methods

    private func getServerCertificates(from serverTrust: SecTrust) -> [SecCertificate]? {
        var certificates: [SecCertificate] = []

        if #available(iOS 15.0, *) {
            guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
                return nil
            }
            certificates = certificateChain
        } else {
            let count = SecTrustGetCertificateCount(serverTrust)
            for index in 0..<count {
                if let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
                    certificates.append(certificate)
                }
            }
        }

        return certificates.isEmpty ? nil : certificates
    }

    private func getServerPublicKeys(from serverTrust: SecTrust) -> [SecKey]? {
        guard let certificates = getServerCertificates(from: serverTrust) else {
            return nil
        }

        let publicKeys = certificates.compactMap { certificate -> SecKey? in
            SecCertificateCopyKey(certificate)
        }

        return publicKeys.isEmpty ? nil : publicKeys
    }

    private func sha256Hash(of certificate: SecCertificate) -> String {
        let certificateData = SecCertificateCopyData(certificate) as Data
        let hash = SHA256.hash(data: certificateData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func sha256Hash(of publicKey: SecKey) -> String {
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return ""
        }

        let hash = SHA256.hash(data: publicKeyData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - URLSessionDelegate

extension SSLPinningService: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host

        do {
            // Try certificate pinning first
            try validateServerTrust(serverTrust, forHost: host)
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } catch {
            #if DEBUG
            print("⚠️ SSL Pinning failed for \(host): \(error.localizedDescription)")
            // In debug mode, allow the connection
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            #else
            // In production, reject the connection
            print("❌ SSL Pinning failed for \(host): \(error.localizedDescription)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            #endif
        }
    }
}

// MARK: - Errors

enum SSLPinningError: LocalizedError {
    case noPinsConfigured(String)
    case noCertificatesFound
    case noPublicKeysFound
    case certificateMismatch
    case publicKeyMismatch

    var errorDescription: String? {
        switch self {
        case .noPinsConfigured(let host):
            return "No certificate pins configured for \(host)"
        case .noCertificatesFound:
            return "No certificates found in server trust"
        case .noPublicKeysFound:
            return "No public keys found in server trust"
        case .certificateMismatch:
            return "Server certificate does not match pinned certificates"
        case .publicKeyMismatch:
            return "Server public key does not match pinned public keys"
        }
    }
}

// MARK: - Certificate Hash Utility

/// Utility for extracting certificate hashes for pinning configuration
struct CertificateHashUtility {
    /// Extracts SHA-256 hash from a certificate file
    /// Usage: Run this in your app during development to get certificate hashes
    static func extractHash(fromCertificateNamed name: String, extension ext: String = "cer") -> String? {
        guard let certPath = Bundle.main.path(forResource: name, ofType: ext),
              let certData = try? Data(contentsOf: URL(fileURLWithPath: certPath)),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
            return nil
        }

        let certificateData = SecCertificateCopyData(certificate) as Data
        let hash = SHA256.hash(data: certificateData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Prints certificate hashes from a URL (for development only)
    static func printCertificateHashes(forURL urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let session = URLSession(configuration: .ephemeral, delegate: CertificateDelegate(), delegateQueue: nil)
        let task = session.dataTask(with: url) { _, _, _ in
            // Completion handled in delegate
        }
        task.resume()
    }

    private class CertificateDelegate: NSObject, URLSessionDelegate {
        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }

            if #available(iOS 15.0, *) {
                if let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
                    for (index, certificate) in certificates.enumerated() {
                        let certificateData = SecCertificateCopyData(certificate) as Data
                        let hash = SHA256.hash(data: certificateData)
                        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
                        print("Certificate \(index) SHA-256: \(hashString)")
                    }
                }
            }

            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
}
