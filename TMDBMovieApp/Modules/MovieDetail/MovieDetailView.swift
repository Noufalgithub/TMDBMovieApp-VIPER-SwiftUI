//
//  MovieDetailView.swift
//  TMDBMovieApp
//
//  View layer for MovieDetail module.
//

import SwiftUI

struct MovieDetailView: View {
    @StateObject private var presenter: MovieDetailPresenter

    init(presenter: MovieDetailPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        Group {
            if presenter.isLoadingDetail && presenter.movie == nil {
                LoadingView(message: "Loading movie details...")
            } else if let error = presenter.detailErrorMessage, presenter.movie == nil {
                ErrorStateView(message: error, retryAction: presenter.retryDetail)
            } else if let movie = presenter.movie {
                contentView(for: movie)
            } else {
                EmptyStateView(
                    systemImage: "film",
                    title: "Not Found",
                    message: "The movie details could not be found."
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if presenter.movie == nil {
                await presenter.fetchMovieDetail()
            }
        }
    }

    // MARK: - Content Views

    private func contentView(for movie: Movie) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection(for: movie)
                
                if let overview = movie.overview, !overview.isEmpty {
                    overviewSection(overview)
                }

                if let trailer = presenter.officialTrailer {
                    trailerSection(for: trailer)
                }

                reviewsSection
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Header Section
    private func headerSection(for movie: Movie) -> some View {
        VStack(spacing: 0) {
            // Backdrop Image
            AsyncImage(url: movie.backdropURL ?? movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color(.systemGray5))
                        .frame(height: 220)
                        .overlay(ProgressView())
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipped()
                case .failure:
                    Rectangle().fill(Color(.systemGray5))
                        .frame(height: 220)
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                @unknown default:
                    EmptyView()
                }
            }

            // Info Bar
            VStack(spacing: 8) {
                Text(movie.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Label(movie.formattedRating, systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                    
                    if let runtime = movie.formattedRuntime {
                        Label(runtime, systemImage: "clock")
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(movie.releaseYear)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)

                if !movie.genreNames.isEmpty {
                    Text(movie.genreNames.joined(separator: " • "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding(.top, 16)
        }
    }

    // MARK: - Overview Section
    private func overviewSection(_ overview: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)
            Text(overview)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(.horizontal)
    }

    // MARK: - Trailer Section
    private func trailerSection(for trailer: Video) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Official Trailer")
                .font(.headline)
                .padding(.horizontal)

            YouTubePlayerView(videoID: trailer.key)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        }
    }

    // MARK: - Reviews Section
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews")
                .font(.headline)
                .padding(.horizontal)

            if presenter.isLoadingReviews && presenter.reviews.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let error = presenter.reviewErrorMessage, presenter.reviews.isEmpty {
                VStack {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry", action: presenter.retryReviews)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if presenter.reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(presenter.reviews) { review in
                        ReviewCardView(review: review)
                    }

                    if presenter.hasMoreReviews {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .task {
                                await presenter.fetchNextReviewPage()
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
