//
//  Networking.swift
//  Flickr Task
//
//  Created by Mahdi BND on 7/28/22.
//

import Foundation
import Alamofire
import Combine

typealias NM = NetworkManager

	// Needs to be a class so it's the same everywhere. classes are reference types.
class NetworkManager {
	static private let apiKey = "f6346688580e57429e7ad310aeceb021"
//	private let secret = "8f7b2088476e2275"
	
	static private let requestBaseUrl = "https://api.flickr.com/services/rest/"
	static private let modifications = "?&api_key=\(apiKey)&format=json&nojsoncallback=1&method="

	static let imageBaseUrl = "https://live.staticflickr.com/"
	static let requestUrl = requestBaseUrl + modifications
	
		/// For general authentication
	static var authType = Auth.none
	
		/// Creates a DataRequest from a Route.
		/// - Parameters:
		///   - route: Each `Route` has it's own method, so you don't need to specify in request
		///   - isPrivate: Set to `true` if endpoint needs authentication
		/// - Returns: The created DataRequest.
	static func request(route: Route, isPrivate: Bool = false) -> DataRequest {
		let headers = isPrivate ? HTTPHeaders([authType.header]) : nil
		let request = AF.request(route, method: route.method, parameters: route.parameters, headers: headers).validate()

		return request
	}

	static func parse<T>(response: DataResponse<T, AFError>) -> T? {
		switch response.result {
			case .failure(let error):
				print(error.localizedDescription)
				return nil
			case .success(let value):
//				print(value)
				return value
		}
	}
}

	/// Routing Pattern to make life easier.
	/// Create an endpoint, add its `url`, `method`, and `parameter`s
enum Route: URLConvertible {
	case upload, recent(Int), search(String)
	
	func asURL() throws -> URL {
		let url = "\(NM.requestUrl)\(self.url)"
		return URL(string: url)!
	}
	
	private var url: String {
		switch self {
			case .upload: return "flickr.blogs.postPhoto"
			case .recent(let page): return "flickr.photos.getRecent&page=\(page)"
			case .search(let text): return "flickr.photos.search&text=\(text)"
		}
	}
	
	var method: HTTPMethod {
		switch self {
			case .upload: return .post
			case .recent, .search: return .get
		}
	}
	
	var parameters: Parameters? {
//		switch self {
//			case .recent(_): return nil
//			case .upload: return nil
//		}
		return nil
	}
	
}

	/// Authentication type and headers all in one place.
enum Auth {
	case none
	case basic(String, String)
	case bearer(String)
	
	var header: HTTPHeader {
		switch self {
			case .basic(let username, let pass):
				return .authorization(username: username, password: pass)
			case .bearer(let token):
				return .authorization(bearerToken: token)
			default:
				return .defaultAcceptEncoding
		}
	}
}

struct NetworkError: Codable {
	var stat: String
	var code: Int
	var message: String
}



extension Encodable {
	/// Returns an object as `JSON`
	/// - Returns: a `[String: Any]` dictionary aka `JSON`
	func makeDict() -> Dictionary<String, Any>? {
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			encoder.dateEncodingStrategy = .iso8601
			let data = try encoder.encode(self)
			let json = try JSONSerialization.jsonObject(with: data, options: [])
			guard let dictionary = json as? [String : Any] else {
				return nil
			}
			return dictionary
		} catch {
			return nil
		}
	}
}
