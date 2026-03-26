import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../models/developer_info.dart';

class DeveloperController extends GetxController {
  final _info = DeveloperInfo(
    name: 'Sourav Sanyal',
    title: 'Full-Stack Flutter Developer',
    bio: 'A passionate software engineer specializing in building high-performance, beautiful, and user-centric mobile applications using Flutter and Firebase. I love creating seamless experiences that delight users and solve real-world problems through clean code and modern architecture.',
    experience: '1.5+ Years',
    projects: '50+',
    skills: [
      DeveloperSkill(name: 'Flutter', icon: FontAwesomeIcons.flutter, color: const Color(0xFF02569B)),
      DeveloperSkill(name: 'Dart', icon: FontAwesomeIcons.code, color: const Color(0xFF0175C2)),
      DeveloperSkill(name: 'Firebase', icon: FontAwesomeIcons.fire, color: const Color(0xFFFFCA28)),
      DeveloperSkill(name: 'Git/GitHub', icon: FontAwesomeIcons.github, color: const Color(0xFF000000)),
      DeveloperSkill(name: 'UI/UX Design', icon: FontAwesomeIcons.bezierCurve, color: const Color(0xFFE91E63)),
      DeveloperSkill(name: 'State Management', icon: FontAwesomeIcons.layerGroup, color: const Color(0xFF3F51B5)),
    ],
    socials: {
      'email': 'sourav.sanyal.dev@gmail.com',
      'github': 'https://github.com/Souravsanyal1',
      'portfolio': 'https://sourav-sanyal.pro.bd',
      'whatsapp': 'https://wa.me/8801930191100',
      'telegram': 'https://t.me/sourav_sanyal',
    },
  ).obs;

  DeveloperInfo get info => _info.value;

  Future<void> refreshData() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Example: Randomly update a stat to demonstrate "real-time" update
    final currentProjects = int.tryParse(info.projects.replaceAll('+', '')) ?? 50;
    _info.value = info.copyWith(
      projects: '${currentProjects + 1}+',
    );
  }
}
