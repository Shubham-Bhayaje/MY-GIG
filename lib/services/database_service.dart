import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== USER PROFILES =====
  
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  Future<void> createUserProfile(UserProfile user) async {
    await _usersCol.doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': user.role.name,
      'rating': user.rating,
      'completedJobs': user.completedJobs,
      'totalReviews': user.totalReviews,
      'skills': user.skills,
      'isVerified': user.isVerified,
      'walletBalance': user.walletBalance,
      'latitude': user.latitude,
      'longitude': user.longitude,
      'joinedAt': Timestamp.fromDate(user.joinedAt),
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    final d = doc.data()!;
    return UserProfile(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == d['role'],
        orElse: () => UserRole.worker,
      ),
      rating: (d['rating'] ?? 0).toDouble(),
      completedJobs: d['completedJobs'] ?? 0,
      totalReviews: d['totalReviews'] ?? 0,
      skills: List<String>.from(d['skills'] ?? []),
      isVerified: d['isVerified'] ?? false,
      walletBalance: (d['walletBalance'] ?? 0).toDouble(),
      latitude: (d['latitude'] ?? 19.2183).toDouble(),
      longitude: (d['longitude'] ?? 72.9781).toDouble(),
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _usersCol.doc(uid).update(data);
  }

  // ===== JOBS =====

  CollectionReference<Map<String, dynamic>> get _jobsCol =>
      _db.collection('jobs');

  Future<void> postJob(GigJob job) async {
    await _jobsCol.doc(job.id).set({
      'title': job.title,
      'description': job.description,
      'payRate': job.payRate,
      'payUnit': job.payUnit,
      'durationMinutes': job.duration.inMinutes,
      'dateTime': Timestamp.fromDate(job.dateTime),
      'latitude': job.latitude,
      'longitude': job.longitude,
      'address': job.address,
      'category': job.category.name,
      'type': job.type.name,
      'status': job.status.name,
      'workersNeeded': job.workersNeeded,
      'workersAccepted': job.workersAccepted,
      'tags': job.tags,
      'posterId': job.posterId,
      'posterName': job.posterName,
      'posterRating': job.posterRating,
      'createdAt': Timestamp.fromDate(job.createdAt),
      'acceptedWorkerIds': [],
    });
  }

  // Real-time stream of all posted jobs
  Stream<List<GigJob>> jobsStream() {
    return _jobsCol
        .where('status', isEqualTo: 'posted')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              return _jobFromFirestore(doc.id, d);
            }).toList());
  }

  // Get jobs posted by a specific user
  Stream<List<GigJob>> myPostedJobsStream(String userId) {
    return _jobsCol
        .where('posterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _jobFromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Accept a job
  Future<void> acceptJob(String jobId, String workerId) async {
    await _jobsCol.doc(jobId).update({
      'acceptedWorkerIds': FieldValue.arrayUnion([workerId]),
      'workersAccepted': FieldValue.increment(1),
      'status': 'accepted',
    });
  }

  // Update job status
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    await _jobsCol.doc(jobId).update({
      'status': status.name,
    });
  }

  // Helper to convert Firestore doc to GigJob
  GigJob _jobFromFirestore(String id, Map<String, dynamic> d) {
    return GigJob(
      id: id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      payRate: (d['payRate'] ?? 0).toDouble(),
      payUnit: d['payUnit'] ?? 'fixed',
      duration: Duration(minutes: d['durationMinutes'] ?? 60),
      dateTime: (d['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (d['latitude'] ?? 19.2183).toDouble(),
      longitude: (d['longitude'] ?? 72.9781).toDouble(),
      address: d['address'] ?? '',
      category: JobCategory.values.firstWhere(
        (c) => c.name == d['category'],
        orElse: () => JobCategory.other,
      ),
      type: JobType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => JobType.oneTime,
      ),
      status: JobStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => JobStatus.posted,
      ),
      workersNeeded: d['workersNeeded'] ?? 1,
      workersAccepted: d['workersAccepted'] ?? 0,
      tags: List<String>.from(d['tags'] ?? []),
      posterId: d['posterId'] ?? '',
      posterName: d['posterName'] ?? '',
      posterRating: (d['posterRating'] ?? 0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
