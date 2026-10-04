class PlaceRating {
  final double rating;
  final int reviewCount;

  const PlaceRating({
    required this.rating,
    required this.reviewCount,
  });
}

const Map<String, PlaceRating> placeRatings = {
  'Gateway of India': PlaceRating(
    rating: 4.6,
    reviewCount: 388087,
  ),

  'Marine Drive': PlaceRating(
    rating: 4.6,
    reviewCount: 13420,
  ),

  'Kanheri Caves': PlaceRating(
    rating: 4.5,
    reviewCount: 9034,
  ),

  'Flora Fountain': PlaceRating(
    rating: 4.5,
    reviewCount: 24592,
  ),
};