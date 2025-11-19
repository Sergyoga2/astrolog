import Foundation

/// Friend model for social features
struct Friend: Identifiable, Codable, Equatable {
    let id: String
    let userId: String  // Current user's ID
    let friendUserId: String  // Friend's user ID
    let friendName: String
    let friendEmail: String?

    // Birth data for compatibility calculations
    let friendBirthData: BirthData?

    // Friend request status
    var status: FriendStatus

    // Compatibility score (cached after calculation)
    var compatibilityScore: Int?  // 0-100
    var compatibilityDescription: String?

    // Metadata
    let requestedAt: Date
    var acceptedAt: Date?
    let requestedBy: String  // userId who initiated the request

    // Synastry chart (cached)
    var synastryChartId: String?

    init(
        id: String = UUID().uuidString,
        userId: String,
        friendUserId: String,
        friendName: String,
        friendEmail: String? = nil,
        friendBirthData: BirthData? = nil,
        status: FriendStatus = .pending,
        compatibilityScore: Int? = nil,
        compatibilityDescription: String? = nil,
        requestedAt: Date = Date(),
        acceptedAt: Date? = nil,
        requestedBy: String,
        synastryChartId: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.friendUserId = friendUserId
        self.friendName = friendName
        self.friendEmail = friendEmail
        self.friendBirthData = friendBirthData
        self.status = status
        self.compatibilityScore = compatibilityScore
        self.compatibilityDescription = compatibilityDescription
        self.requestedAt = requestedAt
        self.acceptedAt = acceptedAt
        self.requestedBy = requestedBy
        self.synastryChartId = synastryChartId
    }
}

// MARK: - Friend Status

enum FriendStatus: String, Codable {
    case pending      // Friend request sent, awaiting acceptance
    case accepted     // Friend request accepted
    case blocked      // User blocked this person
    case declined     // Friend request declined
}

// MARK: - Friend Request

/// Represents a pending friend request
struct FriendRequest: Identifiable, Codable {
    let id: String
    let fromUserId: String
    let fromUserName: String
    let fromUserEmail: String?
    let toUserId: String
    let message: String?
    let createdAt: Date
    var status: FriendStatus

    init(
        id: String = UUID().uuidString,
        fromUserId: String,
        fromUserName: String,
        fromUserEmail: String? = nil,
        toUserId: String,
        message: String? = nil,
        createdAt: Date = Date(),
        status: FriendStatus = .pending
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.fromUserEmail = fromUserEmail
        self.toUserId = toUserId
        self.message = message
        self.createdAt = createdAt
        self.status = status
    }
}

// MARK: - Firestore Extensions

extension Friend {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "friendUserId": friendUserId,
            "friendName": friendName,
            "status": status.rawValue,
            "requestedAt": requestedAt,
            "requestedBy": requestedBy
        ]

        if let email = friendEmail {
            dict["friendEmail"] = email
        }

        if let birthData = friendBirthData {
            dict["friendBirthData"] = [
                "date": ISO8601DateFormatter().string(from: birthData.date),
                "latitude": birthData.latitude,
                "longitude": birthData.longitude,
                "cityName": birthData.cityName,
                "countryName": birthData.countryName,
                "isTimeExact": birthData.isTimeExact
            ]
        }

        if let score = compatibilityScore {
            dict["compatibilityScore"] = score
        }

        if let description = compatibilityDescription {
            dict["compatibilityDescription"] = description
        }

        if let accepted = acceptedAt {
            dict["acceptedAt"] = accepted
        }

        if let chartId = synastryChartId {
            dict["synastryChartId"] = chartId
        }

        return dict
    }

    static func fromDictionary(_ dict: [String: Any]) -> Friend? {
        guard let id = dict["id"] as? String,
              let userId = dict["userId"] as? String,
              let friendUserId = dict["friendUserId"] as? String,
              let friendName = dict["friendName"] as? String,
              let statusString = dict["status"] as? String,
              let status = FriendStatus(rawValue: statusString),
              let requestedBy = dict["requestedBy"] as? String else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        let requestedAt: Date
        if let requestedAtTimestamp = dict["requestedAt"] as? Date {
            requestedAt = requestedAtTimestamp
        } else if let requestedAtString = dict["requestedAt"] as? String,
                  let date = dateFormatter.date(from: requestedAtString) {
            requestedAt = date
        } else {
            requestedAt = Date()
        }

        let acceptedAt: Date?
        if let acceptedAtTimestamp = dict["acceptedAt"] as? Date {
            acceptedAt = acceptedAtTimestamp
        } else if let acceptedAtString = dict["acceptedAt"] as? String,
                  let date = dateFormatter.date(from: acceptedAtString) {
            acceptedAt = date
        } else {
            acceptedAt = nil
        }

        // Parse birth data if present
        var friendBirthData: BirthData? = nil
        if let birthDataDict = dict["friendBirthData"] as? [String: Any],
           let dateString = birthDataDict["date"] as? String,
           let date = dateFormatter.date(from: dateString),
           let latitude = birthDataDict["latitude"] as? Double,
           let longitude = birthDataDict["longitude"] as? Double,
           let cityName = birthDataDict["cityName"] as? String,
           let countryName = birthDataDict["countryName"] as? String,
           let isTimeExact = birthDataDict["isTimeExact"] as? Bool {

            friendBirthData = BirthData(
                date: date,
                timeZone: TimeZone.current, // Will be overridden by actual timezone
                latitude: latitude,
                longitude: longitude,
                cityName: cityName,
                countryName: countryName,
                isTimeExact: isTimeExact
            )
        }

        return Friend(
            id: id,
            userId: userId,
            friendUserId: friendUserId,
            friendName: friendName,
            friendEmail: dict["friendEmail"] as? String,
            friendBirthData: friendBirthData,
            status: status,
            compatibilityScore: dict["compatibilityScore"] as? Int,
            compatibilityDescription: dict["compatibilityDescription"] as? String,
            requestedAt: requestedAt,
            acceptedAt: acceptedAt,
            requestedBy: requestedBy,
            synastryChartId: dict["synastryChartId"] as? String
        )
    }
}

extension FriendRequest {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "fromUserId": fromUserId,
            "fromUserName": fromUserName,
            "toUserId": toUserId,
            "createdAt": createdAt,
            "status": status.rawValue
        ]

        if let email = fromUserEmail {
            dict["fromUserEmail"] = email
        }

        if let msg = message {
            dict["message"] = msg
        }

        return dict
    }

    static func fromDictionary(_ dict: [String: Any]) -> FriendRequest? {
        guard let id = dict["id"] as? String,
              let fromUserId = dict["fromUserId"] as? String,
              let fromUserName = dict["fromUserName"] as? String,
              let toUserId = dict["toUserId"] as? String,
              let statusString = dict["status"] as? String,
              let status = FriendStatus(rawValue: statusString) else {
            return nil
        }

        let createdAt: Date
        if let timestamp = dict["createdAt"] as? Date {
            createdAt = timestamp
        } else if let dateString = dict["createdAt"] as? String,
                  let date = ISO8601DateFormatter().date(from: dateString) {
            createdAt = date
        } else {
            createdAt = Date()
        }

        return FriendRequest(
            id: id,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
            fromUserEmail: dict["fromUserEmail"] as? String,
            toUserId: toUserId,
            message: dict["message"] as? String,
            createdAt: createdAt,
            status: status
        )
    }
}
