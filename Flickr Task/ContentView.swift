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
	
	func overlay(_ condition: Bool, text: String) -> some View {
		Group {
			GeometryReader { proxy in
				if condition {
					Text(text)
						.font(.caption2)
						.frame(width: proxy.size.width, height: proxy.size.height)
						.background(.ultraThinMaterial)
						.multilineTextAlignment(.center)
						.animation(.easeIn.delay(1), value: 0)
				}
			}
		}
	}
	
	func isTapped(_ photo: Photo) -> Bool {
		return model.selectedImage == photo
	}
	
    var body: some View {
		NavigationView {
			ScrollView {
					LazyVGrid(columns: columns) {
						ForEach(model.results) { photo in
							WebImage(url: photo.url)
								.resizable()
								.aspectRatio(1, contentMode: .fit)
								.rotation3DEffect(.degrees(isTapped(photo) ? 180 : 0), axis: (x: 0, y: isTapped(photo) ? 1 : 0, z: 0))
								.overlay(overlay(isTapped(photo), text: photo.title))
								.onTapGesture { withAnimation { model.flipImage(photo) } }
								.id(photo.id)
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
