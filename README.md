# TMDB Movie App (VIPER & SwiftUI) 🎬

A native iOS application built as a coding assessment to discover movies by genre, view movie details, read user reviews, and watch official trailers. This project heavily utilizes modern iOS development practices, specifically **SwiftUI**, **Swift Concurrency (`async/await`)**, and the **VIPER** architectural pattern.

## 📱 Features

- **Genre Discovery**: Browse a list of all official movie genres.
- **Movies by Genre**: View a paginated grid of movies belonging to a selected genre.
- **Movie Details**: Comprehensive information including backdrop poster, rating, release year, runtime, and overview.
- **YouTube Trailers**: Watch the official movie trailer inline directly from the detail screen using a custom `WKWebView` wrapper.
- **User Reviews**: Read paginated user reviews for each movie.
- **Endless Scrolling**: Seamless pagination implemented for both the movie list and user reviews.
- **State Management**: Robust handling of Positive (Success) and Negative (Loading, Error/Network Failure, Empty Data) edge cases.

## 🛠 Tech Stack & Architecture

- **Language**: Swift 5.x
- **UI Framework**: SwiftUI
- **Concurrency**: `async/await`, `@MainActor`, `Task`
- **Architecture**: **VIPER** (View, Interactor, Presenter, Entity, Router)
- **Networking**: Native `URLSession` (Zero 3rd-party dependencies)
- **Testing**: `XCTest` for Unit Tests with mocked network services.
- **Target OS**: iOS 15.0+

### Why VIPER?
The VIPER architecture was chosen to strictly separate concerns, making the codebase highly testable, modular, and easy to maintain. 
- **Views** are purely declarative SwiftUI components.
- **Presenters** (`@ObservableObject`) handle presentation logic and state formatting.
- **Interactors** manage business logic and network fetching.
- **Routers** handle navigation assembly.

## 🚀 Getting Started

### 1. Requirements
- Xcode 13.0 or later
- iOS 15.0+ deployment target

### 2. Setup TMDB API Key
This app uses the [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs). You must provide your own API key to fetch data.

1. Open `TMDBMovieApp/Core/Network/TMDBEndpoint.swift`.
2. Locate the `TMDBConfig` enum.
3. Replace the placeholder with your actual API key:

```swift
enum TMDBConfig {
    static let apiKey = "YOUR_API_KEY_HERE" // <--- Paste your API key here
    ...
}
```

### 3. Running the App
1. Open the project in Xcode.
2. Select a Simulator (e.g., iPhone 15 Pro) or your physical device.
3. Press `Cmd + R` to build and run the application.

## 🧪 Unit Testing
The project includes Unit Tests to verify state transitions and business logic without hitting the live TMDB API.

1. Open the project in Xcode.
2. Navigate to the `TMDBMovieAppTests` folder.
3. Press `Cmd + U` to run the test suite. 

The tests cover:
- Presenter state transitions (Idle -> Loading -> Success/Error)
- Endless scrolling/pagination bounds (`hasMorePages` logic)
- Interactor network error handling via `MockNetworkService`.

---
*Created for iOS Native Coding Assessment.*
