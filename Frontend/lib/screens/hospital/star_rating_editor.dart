import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final bool isControllable;
  final double starSize;

  StarRating({this.starCount = 5, this.rating = .0, required this.onRatingChanged, required this.isControllable, required this.starSize, });

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Colors.grey,
        size: starSize,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: Colors.yellow,
        size: starSize,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: Colors.yellow,
        size: starSize,

      );
    }

    if (isControllable) {
      return new InkResponse(
        onTap: onRatingChanged == null ? null : () =>
            onRatingChanged(index + 1.0),
        child: icon,
      );
    }
    else {
      return icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: new List.generate(starCount, (index) => buildStar(context, index))
    );
  }
}