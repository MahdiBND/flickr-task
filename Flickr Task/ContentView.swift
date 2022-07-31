//
//  ContentView.swift
//  Flickr Task
//
//  Created by Mahdi BND on 7/28/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
	@StateObject var model = PhotoModel()
	let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
	
    var body: some View {
		NavigationView {
			ScrollView {
					LazyVGrid(columns: columns) {
						ForEach(model.results) { photo in
							WebImage(url: photo.url)
								.resizable()
								.aspectRatio(1, contentMode: .fit)
								.onAppear {
									if photo == model.results.last {
										model.loadMore()
									}
								}
						}
					}
				if model.isLoading {
					ProgressView()
				}
			}
			.padding()
			.navigationTitle("Flickr")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					if model.hasError {
						Button(action: model.getRecents) {
							Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
								.foregroundColor(.indigo)
						}
					} else {
						EmptyView()
					}
				}
			}
			
		}
		.searchable(text: $model.searchText)
		.refreshable { model.getRecents() }
		.onSubmit(of: .search) { model.search() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
			.preferredColorScheme(.dark)
    }
}
