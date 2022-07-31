//
//  Photo Model.swift
//  Flickr Task
//
//  Created by Mahdi BND on 7/30/22.
//

import SwiftUI
import Combine
import Alamofire

	// MARK: - Model
struct Photo: Hashable, Codable, Identifiable {
	var id: String
	var secret: String
	var server: String
	var title: String
}


extension Photo {
		// Exmple: https://live.staticflickr.com/65535/52246450112_92fccee16f_c.jpg
		/// Formula: `imageBaseUrl/{server-id}/{id}_{secret}_{size-suffix}.jpg`
	var url: URL {
		return URL(string: NM.imageBaseUrl + "\(server)/\(id)_\(secret)_t.jpg")! // t -> nil
	}
}

// Outer Model for decoding
struct Photos: Codable, Hashable {
	var pages: Int
	var photo: [Photo]
}

struct External: Codable, Hashable {
	var photos: Photos
}


	// MARK: - View Model
class PhotoModel: ObservableObject {
	@Published private var photos = [Photo]()
	@Published private var searchResults = [Photo]()
	@Published var pages = 1
	@Published var isLoading = false
	@Published var searchText = ""
	@Published var hasError = false
	private var tasks = Set<AnyCancellable>()
	private var page = 1
	
	private var canLoadMore: Bool {
		return page + 1 <= pages
	}
	
	var results: [Photo] {
		if searchText.isEmpty {
			return photos
		} else {
			return searchResults
		}
	}
	
	init() { getRecents() }
	
	func getRecents() {
		isLoading = true
		NM.request(route: .recent(1))
			.publishDecodable(type: External.self)
			.sink { response in
				DispatchQueue.main.async {
					if let result = NM.parse(response: response) {
						self.photos = result.photos.photo
						self.pages = result.photos.pages
					} else {
						self.hasError = true
					}
					self.isLoading = false
				}
			}
			.store(in: &tasks)
	}
	
	func loadMore() {
		if canLoadMore {
			isLoading = true
			page = page + 1
			NM.request(route: .recent(page))
				.publishDecodable(type: External.self)
				.sink { response in
					DispatchQueue.main.async {
						if let result = NM.parse(response: response) {
							self.photos.append(contentsOf: result.photos.photo)
						} else {
							self.hasError = true
						}
						self.isLoading = false
					}
				}
				.store(in: &tasks)
		}
	}
	
	func search() {
		NM.request(route: .search(searchText))
			.publishDecodable(type: External.self)
			.sink { response in
				DispatchQueue.main.async {
					if let result = NM.parse(response: response) {
						self.searchResults = result.photos.photo
					} else {
						self.hasError = true
					}
					self.isLoading = false
				}
			}
			.store(in: &tasks)
	}
	
	func refresh() {
		getRecents()
		hasError = false
	}
}
