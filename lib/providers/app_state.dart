import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart' show Distance, LengthUnit, LatLng;
class AppState extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Auth state
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Current user
  UserProfile _currentUser = UserProfile(id: '', name: 'Guest', email: '', role: UserRole.both, joinedAt: DateTime.now());
  UserProfile get currentUser => _currentUser;

  String? _firebaseUid;
  String? get firebaseUid => _firebaseUid;

  // Avatar URL (loaded from Firestore)
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  bool _isLoadingJobs = true;
  bool get isLoadingJobs => _isLoadingJobs;

  StreamSubscription<QuerySnapshot>? _jobsSubscription;

  AppState() {
    _initJobsStream();
  }

  void _initJobsStream() {
    _jobsSubscription = _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allJobs = snapshot.docs.map((doc) {
        final job = GigJob.fromFirestore(doc);
        final distance = const Distance().as(
          LengthUnit.Kilometer,
          LatLng(_mapCenterLat, _mapCenterLng),
          LatLng(job.latitude, job.longitude),
        );
        return job.copyWith(distanceKm: distance.toDouble());
      }).toList();
      _isLoadingJobs = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[FIRESTORE] Error listening to jobs stream: $e');
      _isLoadingJobs = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }

  void login({String? name, String? email, String? phone, String? uid}) {
    _isLoggedIn = true;
    _firebaseUid = uid;
    if (name != null || email != null || phone != null) {
      _currentUser = _currentUser.copyWith(
        id: uid ?? _currentUser.id,
        name: name ?? _currentUser.name,
        email: email ?? _currentUser.email,
        phone: phone ?? _currentUser.phone,
      );
    }
    if (uid != null) {
      _loadAcceptedJobs(uid);
      _loadUserProfile(uid);
    }
    notifyListeners();
  }

  /// Same as login but without notifyListeners — used during initial auth check
  void loginSilent({String? name, String? email, String? phone, String? uid}) {
    _isLoggedIn = true;
    _firebaseUid = uid;
    if (name != null || email != null || phone != null) {
      _currentUser = _currentUser.copyWith(
        id: uid ?? _currentUser.id,
        name: name ?? _currentUser.name,
        email: email ?? _currentUser.email,
        phone: phone ?? _currentUser.phone,
      );
    }
    if (uid != null) {
      _loadAcceptedJobs(uid);
      _loadUserProfile(uid);
    }
  }

  void logout() {
    _isLoggedIn = false;
    _firebaseUid = null;
    _acceptedJobIds.clear();
    notifyListeners();
  }

  // Jobs
  List<GigJob> _allJobs = [];
  List<GigJob> get allJobs => _allJobs;

  // Filters
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  JobCategory? _selectedCategory;
  JobCategory? get selectedCategory => _selectedCategory;

  double _maxDistance = 10.0; // km
  double get maxDistance => _maxDistance;

  double _minPay = 0;
  double get minPay => _minPay;

  double _maxPay = 10000;
  double get maxPay => _maxPay;

  // Map state
  double _mapCenterLat = 19.2183;
  double get mapCenterLat => _mapCenterLat;

  double _mapCenterLng = 72.9781;
  double get mapCenterLng => _mapCenterLng;

  // Selected radius for display: 0=1km, 1=5km, 2=10km, 3=All India
  int _selectedRadiusIndex = 1;
  int get selectedRadiusIndex => _selectedRadiusIndex;
  double get selectedRadius => [1.0, 5.0, 10.0, 99999.0][_selectedRadiusIndex];

  // View mode
  bool _isMapView = true;
  bool get isMapView => _isMapView;

  // Role toggle: worker vs poster mode
  bool _isWorkerMode = true;
  bool get isWorkerMode => _isWorkerMode;
  void setWorkerMode(bool value) {
    _isWorkerMode = value;
    notifyListeners();
  }

  // Selected job for detail view
  GigJob? _selectedJob;
  GigJob? get selectedJob => _selectedJob;

  // My jobs (posted by me)
  List<GigJob> get myPostedJobs =>
      _allJobs.where((j) => j.posterId == _currentUser.id || j.posterId == _firebaseUid).toList();

  // Accepted jobs
  final List<String> _acceptedJobIds = [];
  List<GigJob> get acceptedJobs =>
      _allJobs.where((j) => _acceptedJobIds.contains(j.id)).toList();

  // Max concurrent gigs
  static const int kMaxActiveGigs = 3;

  // Active gigs
  List<GigJob> get activeGigs {
    return acceptedJobs.where(
      (j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress,
    ).toList();
  }

  /// True if the worker reached max active gigs limit.
  bool get hasActiveGig => activeGigs.length >= kMaxActiveGigs;

  bool _checkTimeOverlap(DateTime newStart, Duration newDur) {
    final newEnd = newStart.add(newDur);
    for (final gig in activeGigs) {
      final gigStart = gig.dateTime;
      final gigEnd = gigStart.add(gig.duration);
      // overlap condition: (StartA < EndB) and (EndA > StartB)
      if (newStart.isBefore(gigEnd) && newEnd.isAfter(gigStart)) {
        return true;
      }
    }
    return false;
  }

  // Notifications
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationCount =>
      _notifications.where((n) => n['read'] == false).length;

  // Filtered jobs
  List<GigJob> get filteredJobs {
    return _allJobs.where((job) {
      // Only show posted jobs in the explore list
      if (job.status != JobStatus.posted) return false;
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = job.title.toLowerCase().contains(query);
        final matchesDesc = job.description.toLowerCase().contains(query);
        final matchesTags =
            job.tags.any((tag) => tag.toLowerCase().contains(query));
        final matchesCategory =
            job.category.label.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesTags && !matchesCategory) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && job.category != _selectedCategory) {
        return false;
      }

      // Distance filter
      if (job.distanceKm > selectedRadius) {
        return false;
      }

      // Pay filter
      if (job.payRate < _minPay || job.payRate > _maxPay) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(JobCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setMaxDistance(double distance) {
    _maxDistance = distance;
    notifyListeners();
  }

  void setPayRange(double min, double max) {
    _minPay = min;
    _maxPay = max;
    notifyListeners();
  }

  void setSelectedRadius(int index) {
    _selectedRadiusIndex = index;
    notifyListeners();
  }

  void toggleViewMode() {
    _isMapView = !_isMapView;
    notifyListeners();
  }

  void setMapView(bool isMap) {
    _isMapView = isMap;
    notifyListeners();
  }

  void selectJob(GigJob? job) {
    _selectedJob = job;
    notifyListeners();
  }

  /// Accept a job.
  /// Returns a status string: 'own_job', 'max_reached', 'overlap', 'success', or 'error'
  String acceptJob(String jobId) {
    final jobIndex = _allJobs.indexWhere((j) => j.id == jobId);
    if (jobIndex == -1) return 'error';
    final job = _allJobs[jobIndex];

    // Prevent accepting own posted job
    if (job.posterId == _firebaseUid || job.posterId == _currentUser.id) {
      return 'own_job';
    }

    if (hasActiveGig) return 'max_reached';

    if (_checkTimeOverlap(job.dateTime, job.duration)) return 'overlap';

    if (!_acceptedJobIds.contains(jobId)) {
      _acceptedJobIds.add(jobId);
      _allJobs[jobIndex] = _allJobs[jobIndex].copyWith(
        status: JobStatus.accepted,
        workersAccepted: _allJobs[jobIndex].workersAccepted + 1,
      );

      // Add notification
      _notifications.insert(0, {
        'title': 'Job Accepted',
        'body': 'You accepted "${_allJobs[jobIndex].title}"',
        'time': DateTime.now(),
        'type': 'accepted',
        'read': false,
      });

      // Save to Firestore
      if (_firebaseUid != null) {
        _saveAcceptedJob(jobId);
      }

      notifyListeners();
      return 'success';
    }
    return 'error';
  }

  /// Release / decline an accepted job so the worker can pick a new one.
  void releaseJob(String jobId) {
    _acceptedJobIds.remove(jobId);
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _allJobs[index] = _allJobs[index].copyWith(
        status: JobStatus.posted,
        workersAccepted: (_allJobs[index].workersAccepted - 1).clamp(0, 9999),
      );
    }
    // Add notification
    _notifications.insert(0, {
      'title': 'Gig Released',
      'body': 'You released "${_allJobs[index].title}". You can now accept a new gig.',
      'time': DateTime.now(),
      'type': 'released',
      'read': false,
    });

    // Remove from Firestore
    if (_firebaseUid != null) {
      _removeAcceptedJob(jobId);
    }

    notifyListeners();
  }

  void addJob(GigJob job) {
    _allJobs = [job, ..._allJobs];

    // Save to Firestore
    _saveJobToFirestore(job);

    notifyListeners();
  }

  void updateJobStatus(String jobId, JobStatus status) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _allJobs[index] = _allJobs[index].copyWith(status: status);
      // If completed, credit wallet and increment count locally
      if (status == JobStatus.completed) {
        _creditWalletLocally(_allJobs[index].payRate);
        _incrementCompletedJobsLocally();
      }
      notifyListeners();
    }
  }

  void markNotificationRead(int index) {
    if (index < _notifications.length) {
      _notifications[index] = {..._notifications[index], 'read': true};
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications = _notifications
        .map((n) => {...n, 'read': true})
        .toList();
    notifyListeners();
  }

  bool isJobAccepted(String jobId) => _acceptedJobIds.contains(jobId);

  /// Check if the current user is the poster of a given job.
  bool isOwnJob(GigJob job) =>
      job.posterId == _firebaseUid || job.posterId == _currentUser.id;

  void updateUserRole(UserRole role) {
    _currentUser = _currentUser.copyWith(role: role);
    notifyListeners();
  }

  // ===== WALLET & RATING (FUNCTIONAL) =====

  /// Credit wallet locally after transaction completion.
  void _creditWalletLocally(double amount) {
    _currentUser = _currentUser.copyWith(
      walletBalance: _currentUser.walletBalance + amount,
    );
    _notifications.insert(0, {
      'title': 'Payment Received',
      'body': '₹${amount.toInt()} credited to your wallet',
      'time': DateTime.now(),
      'type': 'payment',
      'read': false,
    });
    notifyListeners();
  }

  /// Increment completed jobs count locally.
  void _incrementCompletedJobsLocally() {
    _currentUser = _currentUser.copyWith(
      completedJobs: _currentUser.completedJobs + 1,
      isVerified: (_currentUser.completedJobs + 1) >= 3,
    );
  }

  /// Add a rating (rolling average).
  void addRating(double newRating) {
    final totalReviews = _currentUser.totalReviews;
    final currentRating = _currentUser.rating;
    // Weighted average: (old * count + new) / (count + 1)
    final updatedRating = totalReviews == 0
        ? newRating
        : ((currentRating * totalReviews) + newRating) / (totalReviews + 1);
    _currentUser = _currentUser.copyWith(
      rating: double.parse(updatedRating.toStringAsFixed(1)),
      totalReviews: totalReviews + 1,
    );
    _notifications.insert(0, {
      'title': 'New Review',
      'body': 'You received a ${newRating.toStringAsFixed(1)}⭐ rating!',
      'time': DateTime.now(),
      'type': 'review',
      'read': false,
    });
    _saveUserProfileToFirestore();
    notifyListeners();
  }

  /// Withdraw from wallet atomically using transaction.
  Future<bool> withdrawFromWallet(double amount) async {
    if (_firebaseUid == null) return false;
    if (amount <= 0) return false;

    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(_firebaseUid);
        final userSnap = await transaction.get(userRef);

        if (!userSnap.exists) throw Exception('User not found');
        
        final data = userSnap.data()!;
        final currentBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
        
        if (currentBalance < amount) {
          throw Exception('Insufficient balance');
        }

        transaction.update(userRef, {
          'walletBalance': FieldValue.increment(-amount),
        });
      });

      _currentUser = _currentUser.copyWith(
        walletBalance: _currentUser.walletBalance - amount,
      );
      _notifications.insert(0, {
        'title': 'Withdrawal Successful',
        'body': '₹${amount.toInt()} withdrawn from wallet',
        'time': DateTime.now(),
        'type': 'payment',
        'read': false,
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[FIRESTORE] Withdrawal failed: $e');
      rethrow;
    }
  }

  /// Mark a job as complete using Firestore transaction.
  Future<void> completeJob(String jobId) async {
    if (_firebaseUid == null) return;

    try {
      await _db.runTransaction((transaction) async {
        final jobRef = _db.collection('jobs').doc(jobId);
        final jobSnap = await transaction.get(jobRef);

        if (!jobSnap.exists) throw Exception('Job not found');
        
        final data = jobSnap.data()!;
        if (data['status'] == JobStatus.completed.name) {
          throw Exception('Job already completed');
        }

        transaction.update(jobRef, {'status': JobStatus.completed.name});

        final userRef = _db.collection('users').doc(_firebaseUid);
        transaction.update(userRef, {
          'walletBalance': FieldValue.increment(data['payRate']),
          'completedJobs': FieldValue.increment(1),
        });
      });

      updateJobStatus(jobId, JobStatus.completed);
      _acceptedJobIds.remove(jobId);
      _removeAcceptedJob(jobId);
    } catch (e) {
      debugPrint('[FIRESTORE] Complete job failed: $e');
      rethrow;
    }
  }

  void updateSkills(List<String> skills) {
    _currentUser = _currentUser.copyWith(skills: skills);
    // Save to Firestore
    if (_firebaseUid != null) {
      _db.collection('users').doc(_firebaseUid).update({'skills': skills}).catchError(
        (e) => debugPrint('[FIRESTORE] Error saving skills: $e'),
      );
    }
    notifyListeners();
  }

  // ===== FIRESTORE PERSISTENCE =====

  Future<void> _saveAcceptedJob(String jobId) async {
    try {
      await _db.collection('users').doc(_firebaseUid).collection('accepted_jobs').doc(jobId).set({
        'jobId': jobId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FIRESTORE] Saved accepted job: $jobId');
    } catch (e) {
      debugPrint('[FIRESTORE] Error saving accepted job: $e');
    }
  }

  Future<void> _removeAcceptedJob(String jobId) async {
    try {
      await _db.collection('users').doc(_firebaseUid).collection('accepted_jobs').doc(jobId).delete();
      debugPrint('[FIRESTORE] Removed accepted job: $jobId');
    } catch (e) {
      debugPrint('[FIRESTORE] Error removing accepted job: $e');
    }
  }

  Future<void> _loadAcceptedJobs(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('accepted_jobs').get();
      for (final doc in snapshot.docs) {
        final jobId = doc['jobId'] as String;
        if (!_acceptedJobIds.contains(jobId)) {
          _acceptedJobIds.add(jobId);
          // Update local job status
          final index = _allJobs.indexWhere((j) => j.id == jobId);
          if (index != -1) {
            _allJobs[index] = _allJobs[index].copyWith(
              status: JobStatus.accepted,
              workersAccepted: _allJobs[index].workersAccepted + 1,
            );
          }
        }
      }
      debugPrint('[FIRESTORE] Loaded ${snapshot.docs.length} accepted jobs');
      notifyListeners();
    } catch (e) {
      debugPrint('[FIRESTORE] Error loading accepted jobs: $e');
    }
  }

  Future<void> _saveJobToFirestore(GigJob job) async {
    try {
      await _db.collection('jobs').doc(job.id).set({
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
        'posterId': _firebaseUid ?? job.posterId,
        'posterName': job.posterName,
        'posterRating': job.posterRating,
        'createdAt': Timestamp.fromDate(job.createdAt),
      });
      debugPrint('[FIRESTORE] Saved job: ${job.title}');
    } catch (e) {
      debugPrint('[FIRESTORE] Error saving job: $e');
    }
  }

  /// Load user profile (wallet, rating, skills, etc.) from Firestore.
  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = _currentUser.copyWith(
          walletBalance: (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          completedJobs: (data['completedJobs'] as int?) ?? 0,
          totalReviews: (data['totalReviews'] as int?) ?? 0,
          skills: List<String>.from(data['skills'] ?? []),
          isVerified: (data['isVerified'] as bool?) ?? false,
          name: data['name'] as String? ?? _currentUser.name,
        );
        // Load avatar
        _avatarUrl = data['avatarUrl'] as String?;
        debugPrint('[FIRESTORE] Loaded user profile: wallet=\u20b9${_currentUser.walletBalance}, rating=${_currentUser.rating}, hasAvatar=${_avatarUrl != null}');
        notifyListeners();
      } else {
        // First login — create profile document
        _saveUserProfileToFirestore();
        debugPrint('[FIRESTORE] Created new user profile');
      }
    } catch (e) {
      debugPrint('[FIRESTORE] Error loading user profile: $e');
    }
  }

  /// Save user profile data to Firestore.
  Future<void> _saveUserProfileToFirestore() async {
    if (_firebaseUid == null) return;
    try {
      await _db.collection('users').doc(_firebaseUid).set({
        'name': _currentUser.name,
        'email': _currentUser.email,
        'phone': _currentUser.phone,
        'walletBalance': _currentUser.walletBalance,
        'rating': _currentUser.rating,
        'completedJobs': _currentUser.completedJobs,
        'totalReviews': _currentUser.totalReviews,
        'skills': _currentUser.skills,
        'isVerified': _currentUser.isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[FIRESTORE] Saved user profile');
    } catch (e) {
      debugPrint('[FIRESTORE] Error saving user profile: $e');
    }
  }
}
