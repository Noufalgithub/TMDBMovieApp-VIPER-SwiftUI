//
//  ContentView.swift
//  TMDBMovieApp
//
//  Created by Noufal Ibrahim on 27/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GenreListRouter.createModule()
    }
}

#Preview {
    ContentView()
}
