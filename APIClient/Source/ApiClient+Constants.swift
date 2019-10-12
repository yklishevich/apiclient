import Foundation

extension APIClient {    
    /// Used usually in model objects to serialize/deserialize dates.
    static var quiryStringDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")! // TimeZone(forSecondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // For most fixed formats a POSIX locale should be used.
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }
    
    /// Used for parsing dates in http response headers.
    /// Parse strings like "Thu, 22 Jun 2017 08:26:49 GMT"
    static var httpHeaderDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current // TimeZone(forSecondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // For most fixed formats a POSIX locale should be used.
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        return dateFormatter
    }()
}
