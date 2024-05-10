import 'package:flutter/material.dart';

class Constants {
  static const String teamsCollectionPath = "Teams";
  static const String driversCollectionPath = "Drivers";
  
  // Other constants as needed
}
class AppColors {
  static const primaryColor =
      Color(0xFFD50000); // Formula 1 Red for buttons and accents
  static const primaryTextColor = Colors.white;

  static const secondaryColor =
      Color(0xFF0D47A1); // Deep Blue for secondary buttons
  static const accentColor = Color(0xFFFFD740); // Amber for icons and accents

    static const backgroundColor =
      Color(0xFFF4F4F4); // Light grey for page backgrounds

  static const cardColor = Colors.white; // White background for cards
  static const errorColor = Color(0xFFB00020); // Red for errors
  static const dividerColor = Color(0xFFE0E0E0); // Light grey for dividers
  static const secondaryTextColor =
      Colors.black54; // Dim text for less emphasis
  static const iconColor = Color(0xFF424242); // Dark grey for icons

  static const buttonColor = Color(0xFF1A237E); // Dark Blue for primary buttons

  static const textColor =
      Colors.black87; // Dark text for readability on light backgrounds

  static const buttonTextColor = Colors.white; // White text for buttons


}


class AppStyles {
  static final headingStyle = TextStyle(
      color: AppColors.textColor, fontSize: 20, fontWeight: FontWeight.bold);
  static final textStyle = TextStyle(color: AppColors.textColor, fontSize: 16);
  static final inputTextStyle =
      TextStyle(color: AppColors.textColor, fontSize: 16);
  static final buttonStyle = TextStyle(
      color: AppColors.buttonTextColor,
      fontSize: 16,
      fontWeight: FontWeight.bold);
}


