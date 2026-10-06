import 'package:flutter/material.dart';

class OnboardingItem {
  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
}
