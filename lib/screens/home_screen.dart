import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../providers/app_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/glass_card.dart';
import '../widgets/job_card.dart';
import '../widgets/user_avatar.dart';
import 'job_detail_screen.dart';
import 'post_job_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  bool _showSearchFilters = false;
  LatLng? _userLocation;
  bool _locationLoading = true;
  String _locationName = 'Detecting...';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationLoading = false);
        return;
      }

      // Check & request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationLoading = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = userLatLng;
          _locationLoading = false;
        });

        // Move the map camera to the user's real location
        try {
          _mapController.move(userLatLng, 14.0);
        } catch (_) {
          // MapController may not be ready yet; ignore
        }

        // Reverse geocode to get place name
        try {
          final placemarks = await geo.placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty && mounted) {
            final p = placemarks.first;
            final area = p.subLocality?.isNotEmpty == true
                ? p.subLocality!
                : (p.locality ?? '');
            final city = p.locality ?? '';
            final name = area == city
                ? '$city, ${p.country ?? ''}'
                : '$area, $city';
            setState(() => _locationName = name);
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: Stack(
            children: [
              // Background gradient
              _buildBackground(),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // App bar area
                    _buildAppBar(state),

                    // Content based on role
                    if (state.isWorkerMode) ...[
                      // WORKER VIEW — find & accept gigs
                      _buildSearchBar(state),
                      _buildCategoryRow(state),
                      _buildControls(state),
                      Expanded(
                        child: state.isMapView
                            ? _buildMapView(state)
                            : _buildListView(state),
                      ),
                    ] else ...[
                      // POSTER VIEW — manage your posted gigs
                      Expanded(
                        child: _buildPosterView(state),
                      ),
                    ],
                  ],
                ),
              ),

              // Floating job count badge (worker map only)
              if (state.isWorkerMode && state.isMapView)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildJobCountBadge(state),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return Container(color: const Color(0xFF050505));
  }

  Widget _buildAppBar(AppState state) {
    final user = state.currentUser;
    final greeting = _getGreeting();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + Greeting + Toggle
          Row(
            children: [
              // Profile avatar
              UserAvatar(
                avatarUrl: state.avatarUrl,
                name: user.name,
                radius: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      user.name.isNotEmpty ? user.name : 'Guest',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
              // Worker / Poster segmented toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.primaryMid,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn('Worker', state.isWorkerMode, () => state.setWorkerMode(true)),
                    _buildToggleBtn('Poster', !state.isWorkerMode, () => state.setWorkerMode(false)),
                  ],
                ),
              ),
            ],
          ),
          // Location
          if (state.isWorkerMode) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 48),
                Icon(Icons.near_me_rounded, size: 11, color: AppColors.accentCyan),
                const SizedBox(width: 4),
                Text(
                  _locationName,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: -0.1),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildToggleBtn(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Color(0xFF050505) : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        borderRadius: 14,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: state.setSearchQuery,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search for gigs nearby...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // Filter button
            IconButton(
              onPressed: () {
                setState(() => _showSearchFilters = !_showSearchFilters);
              },
              icon: Icon(
                Icons.tune_rounded,
                color: _showSearchFilters
                    ? AppColors.accentCyan
                    : AppColors.textMuted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildCategoryRow(AppState state) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          CategoryChip(
            category: JobCategory.teaching,
            isSelected: false,
            onTap: () {},
          ),
          ...JobCategory.values.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                category: cat,
                isSelected: state.selectedCategory == cat,
                onTap: () {
                  if (state.selectedCategory == cat) {
                    state.setSelectedCategory(null);
                  } else {
                    state.setSelectedCategory(cat);
                  }
                },
              ),
            );
          }),
        ].skip(1).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildControls(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          // Result count
          Flexible(
            child: Text(
              state.selectedRadiusIndex == 3
                  ? '${state.filteredJobs.length} gigs across India'
                  : '${state.filteredJobs.length} gigs nearby',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Radius selector
          _buildRadiusSelector(state),
          const SizedBox(width: 8),
          // View toggle
          GlassCard(
            padding: const EdgeInsets.all(0),
            borderRadius: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggleButton(
                  Icons.map_outlined,
                  state.isMapView,
                  () => state.setMapView(true),
                ),
                _buildViewToggleButton(
                  Icons.list_rounded,
                  !state.isMapView,
                  () => state.setMapView(false),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildRadiusSelector(AppState state) {
    final radii = ['1km', '5km', '10km', '🇮🇳 All'];
    return GlassCard(
      padding: const EdgeInsets.all(2),
      borderRadius: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (index) {
          final isSelected = state.selectedRadiusIndex == index;
          return GestureDetector(
            onTap: () => state.setSelectedRadius(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (index == 3
                        ? AppColors.accentPurple.withValues(alpha: 0.2)
                        : AppColors.accentCyan.withValues(alpha: 0.2))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                radii[index],
                style: TextStyle(
                  color: isSelected
                      ? (index == 3 ? AppColors.accentPurple : AppColors.accentCyan)
                      : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentCyan.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.accentCyan : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildMapView(AppState state) {
    if (state.isLoadingJobs) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentCyan),
      );
    }
    final jobs = state.filteredJobs;
    // Use real GPS location if available, fallback to mock
    final mapCenter = _userLocation ?? 
        LatLng(state.currentUser.latitude, state.currentUser.longitude);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          // Real OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 14.0,
              minZoom: 10,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Dark map tiles (CartoDB Dark Matter)
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                userAgentPackageName: 'com.hyperlocalgig.app',
                maxZoom: 19,
              ),
              // Job markers
              MarkerLayer(
                markers: [
                  // User location marker
                  Marker(
                    point: mapCenter,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 60 + (_pulseController.value * 20),
                          height: 60 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentCyan.withValues(
                              alpha: 0.15 * (1 - _pulseController.value),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentCyan,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentCyan.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Gig markers
                  ...jobs.map((job) {
                    // Build distance label
                    final distLabel = job.distanceKm < 1
                        ? '${(job.distanceKm * 1000).toInt()}m'
                        : '${job.distanceKm.toStringAsFixed(1)}km';
                    // Truncate title for pin
                    final shortTitle = job.title.length > 18
                        ? '${job.title.substring(0, 16)}…'
                        : job.title;

                    return Marker(
                      point: LatLng(job.latitude, job.longitude),
                      width: 90,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailScreen(job: job),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(job.category.icon, size: 14, color: job.category.color),
                              const SizedBox(width: 4),
                              Text(
                                '₹${job.payRate.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // ===== Map Controls (Google Maps style) =====
          // My Location button
          Positioned(
            right: 12,
            bottom: 16,
            child: _buildMapControl(
              icon: Icons.my_location_rounded,
              color: AppColors.accentCyan,
              onTap: () async {
                if (_userLocation != null) {
                  _mapController.move(_userLocation!, 15.0);
                } else {
                  await _detectLocation();
                  if (_userLocation != null) {
                    _mapController.move(_userLocation!, 15.0);
                  }
                }
              },
            ),
          ),
          // Zoom controls
          Positioned(
            right: 12,
            bottom: 76,
            child: Column(
              children: [
                _buildMapControl(
                  icon: Icons.add_rounded,
                  onTap: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(
                      _mapController.camera.center,
                      zoom.clamp(10.0, 18.0),
                    );
                  },
                ),
                const SizedBox(height: 2),
                _buildMapControl(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(
                      _mapController.camera.center,
                      zoom.clamp(10.0, 18.0),
                    );
                  },
                ),
              ],
            ),
          ),
          // Compass / Reset North
          Positioned(
            right: 12,
            top: 12,
            child: _buildMapControl(
              icon: Icons.explore_rounded,
              onTap: () {
                _mapController.rotate(0);
              },
            ),
          ),
          // Loading indicator
          if (_locationLoading)
            Positioned(
              left: 12,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentCyan,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Locating...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListView(AppState state) {
    if (state.isLoadingJobs) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentCyan),
      );
    }
    final jobs = state.filteredJobs;
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No gigs found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Available Gigs',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${jobs.length} found',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 100),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(job: job),
                    ),
                  );
                },
              ).animate()
                .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                .slideX(begin: 0.05, duration: 300.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJobCountBadge(AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentCyan,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${state.filteredJobs.length} active gigs within ${state.selectedRadius.toInt()}km',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.3, duration: 400.ms);
  }

  // ===== POSTER VIEW =====
  Widget _buildPosterView(AppState state) {
    final myGigs = state.myPostedJobs;
    final activeGigs = myGigs.where((j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress).length;
    final completedGigs = myGigs.where((j) => j.status == JobStatus.completed).length;
    final totalSpent = myGigs.fold<double>(0, (sum, j) => sum + j.payRate);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 12),

        // Compact analytics cards
        Row(
          children: [
            Expanded(child: _buildPosterStat('Active', '$activeGigs')),
            const SizedBox(width: 10),
            Expanded(child: _buildPosterStat('Total', '${myGigs.length}')),
            const SizedBox(width: 10),
            Expanded(child: _buildPosterStat('Done', '$completedGigs')),
          ],
        ),

        const SizedBox(height: 20),

        // Large clean CTA
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostJobScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.accentCyan,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Color(0xFF050505), size: 20),
                SizedBox(width: 8),
                Text(
                  'Post New Gig',
                  style: TextStyle(
                    color: Color(0xFF050505),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Total spent card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Budget Posted', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      '\u20b9${totalSpent.toStringAsFixed(0)}',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick tips for posters
        const Text(
          'Quick Tips',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
        const SizedBox(height: 12),
        _buildTipCard(Icons.description_outlined, 'Write clear descriptions', 'Detailed gig descriptions attract 3x more applicants'),
        const SizedBox(height: 8),
        _buildTipCard(Icons.location_on_outlined, 'Set accurate location', 'Workers nearby can find your gig faster'),
        const SizedBox(height: 8),
        _buildTipCard(Icons.payments_outlined, 'Fair pricing', 'Competitive pay rates get filled 2x faster'),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTipCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterJobCard(GigJob job, AppState state) {
    final statusColor = switch (job.status) {
      JobStatus.posted => AppColors.accentCyan,
      JobStatus.accepted => AppColors.accentGreen,
      JobStatus.inProgress => AppColors.accentOrange,
      JobStatus.completed => AppColors.accentPurple,
      JobStatus.cancelled => AppColors.error,
    };
    final statusLabel = switch (job.status) {
      JobStatus.posted => 'Open',
      JobStatus.accepted => 'Accepted',
      JobStatus.inProgress => 'In Progress',
      JobStatus.completed => 'Completed',
      JobStatus.cancelled => 'Cancelled',
    };

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.address,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${job.payRate.toInt()}',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          // Show complete button for accepted gigs
          if (job.status == JobStatus.accepted || job.status == JobStatus.inProgress) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => state.completeJob(job.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outlined, color: AppColors.accentGreen, size: 16),
                          SizedBox(width: 6),
                          Text('Mark Complete', style: TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}


class _PinPointerPainter extends CustomPainter {
  final Color color;
  _PinPointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
