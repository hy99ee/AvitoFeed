import Foundation

struct Item: Codable, Equatable, ApiNetworkDataType {
    let advertisements: [Advertisement]
}

protocol CollectionDataType {}

struct Advertisement: Codable, Equatable, CollectionDataType {
    let id, title, price, location: String
    let imageURL: String
    let createdDate: String

    enum CodingKeys: String, CodingKey {
        case id, title, price, location
        case imageURL = "image_url"
        case createdDate = "created_date"
    }
}

struct AdvertisementPlaceHolder: CollectionDataType {
    let id: UUID

    private init() {
        self.id = UUID()
    }

    static var placeholderSequence: [AdvertisementPlaceHolder] {
        Array(repeating: AdvertisementPlaceHolder(), count: 10)
    }
}

struct AdvertisementError: CollectionDataType {
    let id: UUID

    private init() {
        self.id = UUID()
    }

    static var errorSequence: [AdvertisementError] {
        Array(repeating: AdvertisementError(), count: 10)
    }
}
//
//extension Array: ApiValidateResponseType where Element == Advertisement {
//
//}

//extension Array: ApiNetworkDataType where Element == Advertisement {
//    func validate() -> Bool {
//        true
//    }
//}

