import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum JobCategory {
  teaching('Teaching', Icons.school, Color(0xFF5B9BD5)),
  labour('Labour', Icons.construction, Color(0xFFD4886C)),
  delivery('Delivery', Icons.local_shipping, Color(0xFF6BBF8A)),
  cleaning('Cleaning', Icons.cleaning_services, Color(0xFF9B7EB5)),
  tech('Tech', Icons.computer, Color(0xFF7986CB)),
  babysitting('Babysitting', Icons.child_care, Color(0xFFD4728C)),
  electrical('Electrical', Icons.electrical_services, Color(0xFFD4C06A)),
  plumbing('Plumbing', Icons.plumbing, Color(0xFF5CABA1)),
  cooking('Cooking', Icons.restaurant, Color(0xFFCC7A7A)),
  driving('Driving', Icons.directions_car, Color(0xFF5BA8C8)),
  gardening('Gardening', Icons.yard, Color(0xFF6BBF8A)),
  other('Other', Icons.more_horiz, Color(0xFF8A9AA4));

  const JobCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum JobStatus {
  posted('Posted', Color(0xFF448AFF)),
  accepted('Accepted', Color(0xFFFFAB40)),
  inProgress('In Progress', Color(0xFF9C7CFF)),
  completed('Completed', Color(0xFF69F0AE)),
  cancelled('Cancelled', Color(0xFFFF5252));

  const JobStatus(this.label, this.color);
  final String label;
  final Color color;
}

enum JobType {
  oneTime,
  recurring,
}

class GigJob {
  final String id;
  final String title;
  final String description;
  final double payRate;
  final String payUnit; // "per hour", "fixed", "per day"
  final Duration duration;
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final String address;
  final JobCategory category;
  final JobStatus status;
  final JobType type;
  final int workersNeeded;
  final int workersAccepted;
  final List<String> tags;
  final String posterId;
  final String posterName;
  final double posterRating;
  final String posterAvatar;
  final DateTime createdAt;
  final double distanceKm;
  final List<String> acceptedWorkerIds;

  const GigJob({
    required this.id,
    required this.title,
    required this.description,
    required this.payRate,
    this.payUnit = 'fixed',
    required this.duration,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.category,
    this.status = JobStatus.posted,
    this.type = JobType.oneTime,
    this.workersNeeded = 1,
    this.workersAccepted = 0,
    this.tags = const [],
    required this.posterId,
    required this.posterName,
    this.posterRating = 0.0,
    this.posterAvatar = '',
    required this.createdAt,
    this.distanceKm = 0.0,
    this.acceptedWorkerIds = const [],
  });

  GigJob copyWith({
    String? id,
    String? title,
    String? description,
    double? payRate,
    String? payUnit,
    Duration? duration,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    String? address,
    JobCategory? category,
    JobStatus? status,
    JobType? type,
    int? workersNeeded,
    int? workersAccepted,
    List<String>? tags,
    String? posterId,
    String? posterName,
    double? posterRating,
    String? posterAvatar,
    DateTime? createdAt,
    double? distanceKm,
    List<String>? acceptedWorkerIds,
  }) {
    return GigJob(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      payRate: payRate ?? this.payRate,
      payUnit: payUnit ?? this.payUnit,
      duration: duration ?? this.duration,
      dateTime: dateTime ?? this.dateTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      category: category ?? this.category,
      status: status ?? this.status,
      type: type ?? this.type,
      workersNeeded: workersNeeded ?? this.workersNeeded,
      workersAccepted: workersAccepted ?? this.workersAccepted,
      tags: tags ?? this.tags,
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
      posterRating: posterRating ?? this.posterRating,
      posterAvatar: posterAvatar ?? this.posterAvatar,
      createdAt: createdAt ?? this.createdAt,
      distanceKm: distanceKm ?? this.distanceKm,
      acceptedWorkerIds: acceptedWorkerIds ?? this.acceptedWorkerIds,
    );
  }

  factory GigJob.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GigJob(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      payRate: (data['payRate'] as num?)?.toDouble() ?? 0.0,
      payUnit: data['payUnit'] ?? 'fixed',
      duration: Duration(minutes: data['durationMinutes'] ?? 60),
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] ?? '',
      category: JobCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => JobCategory.other,
      ),
      status: JobStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => JobStatus.posted,
      ),
      type: JobType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => JobType.oneTime,
      ),
      workersNeeded: data['workersNeeded'] ?? 1,
      workersAccepted: data['workersAccepted'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      posterId: data['posterId'] ?? '',
      posterName: data['posterName'] ?? 'Unknown',
      posterRating: (data['posterRating'] as num?)?.toDouble() ?? 0.0,
      posterAvatar: data['posterAvatar'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      distanceKm: 0.0,
      acceptedWorkerIds: List<String>.from(data['acceptedWorkerIds'] ?? []),
    );
  }
}
