import 'package:flutter/material.dart';

class DeveloperSkill {
  final String name;
  final dynamic icon;
  final Color color;

  DeveloperSkill({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class DeveloperInfo {
  final String name;
  final String title;
  final String bio;
  final String experience;
  final String projects;
  final List<DeveloperSkill> skills;
  final Map<String, String> socials;

  DeveloperInfo({
    required this.name,
    required this.title,
    required this.bio,
    required this.experience,
    required this.projects,
    required this.skills,
    required this.socials,
  });

  DeveloperInfo copyWith({
    String? name,
    String? title,
    String? bio,
    String? experience,
    String? projects,
    List<DeveloperSkill>? skills,
    Map<String, String>? socials,
  }) {
    return DeveloperInfo(
      name: name ?? this.name,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      socials: socials ?? this.socials,
    );
  }
}
