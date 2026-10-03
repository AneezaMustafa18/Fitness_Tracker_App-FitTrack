// Path in your project:
// lib/features/activity/presentation/screens/live_tracking_screen.dart
//
// Packages required in pubspec.yaml (already added for you):
//   geolocator: ^13.0.2
//   google_maps_flutter: ^2.9.0
//   permission_handler: ^11.3.1
//
// SETUP NEEDED BEFORE THIS WORKS:
// 1) Android: add INTERNET, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION
//    permissions in android/app/src/main/AndroidManifest.xml, and your
//    Google Maps API key inside <application> as:
//    <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
// 2) iOS: add NSLocationWhenInUseUsageDescription in ios/Runner/Info.plist,
//    and call GMSServices.provideAPIKey("YOUR_KEY") in AppDelegate.swift.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';

enum _TrackingState { idle, tracking, paused, finished }

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  // ============================================================
  // STATE
  // ============================================================

  _TrackingState _state = _TrackingState.idle;

  String _selectedType = 'Running';

  final List<String> _activityTypes = ['Walking', 'Running', 'Cycling'];

  GoogleMapController? _mapController;

  StreamSubscription<Position>? _positionSubscription;

  final List<LatLng> _routePoints = [];

  Position? _lastPosition;

  double _distanceMeters = 0;

  int _elapsedSeconds = 0;

  Timer? _timer;

  bool _isSaving = false;

  bool _isCheckingPermission = true;

  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _prepareLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================

  Future<void> _prepareLocation() async {
    setState(() {
      _isCheckingPermission = true;
      _permissionError = null;
    });

    try {
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _permissionError =
          'Location services are turned off. Please enable GPS to start tracking.';
          _isCheckingPermission = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _permissionError =
          'Location permission is required for live tracking.';
          _isCheckingPermission = false;
        });
        return;
      }

      final Position current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _lastPosition = current;
        _routePoints.add(LatLng(current.latitude, current.longitude));
        _isCheckingPermission = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _permissionError = 'Unable to get your location. Please try again.';
        _isCheckingPermission = false;
      });
    }
  }

  // ============================================================
  // START / PAUSE / RESUME / STOP
  // ============================================================

  void _startTracking() {
    setState(() {
      _state = _TrackingState.tracking;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
    });

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen(_onPositionUpdate);
  }

  void _pauseTracking() {
    _timer?.cancel();
    _positionSubscription?.pause();

    setState(() {
      _state = _TrackingState.paused;
    });
  }

  void _resumeTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
    });

    _positionSubscription?.resume();

    setState(() {
      _state = _TrackingState.tracking;
    });
  }

  Future<void> _stopTracking() async {
    _timer?.cancel();
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    setState(() {
      _state = _TrackingState.finished;
    });
  }

  void _onPositionUpdate(Position position) {
    if (!mounted) return;

    if (_lastPosition != null) {
      final double segment = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Ignore GPS jitter (tiny jumps while standing still).
      if (segment > 1.5) {
        _distanceMeters += segment;
      }
    }

    _lastPosition = position;

    final LatLng point = LatLng(position.latitude, position.longitude);

    setState(() {
      _routePoints.add(point);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(point));
  }

  // ============================================================
  // SAVE ACTIVITY (reuses existing ActivityProvider + Activity entity)
  // ============================================================

  Future<void> _saveSession() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final double distanceKm = _distanceMeters / 1000;
    final int durationMinutes = (_elapsedSeconds / 60).ceil().clamp(0, 999999);

    // Rough MET-based calorie estimate per activity type.
    final double caloriesPerKm = switch (_selectedType) {
      'Walking' => 55,
      'Running' => 70,
      'Cycling' => 35,
      _ => 60,
    };

    final int estimatedCalories = (distanceKm * caloriesPerKm).round();

    // Average step length ~0.78m for walking/running; not used for cycling.
    final int estimatedSteps = _selectedType == 'Cycling'
        ? 0
        : (_distanceMeters / 0.78).round();

    final activity = Activity(
      id: '',
      title: '$_selectedType (Live Tracked)',
      type: _selectedType,
      date: DateTime.now(),
      steps: estimatedSteps,
      calories: estimatedCalories,
      durationMinutes: durationMinutes == 0 ? 1 : durationMinutes,
      distance: double.parse(distanceKm.toStringAsFixed(2)),
    );

    try {
      await context.read<ActivityProvider>().createActivity(activity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save session. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.normalText,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Live Tracking',
          style: TextStyle(
            color: AppColors.normalText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _isCheckingPermission
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        )
            : _permissionError != null
            ? _buildPermissionError()
            : _buildTrackingUI(),
      ),
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _permissionError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _prepareLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingUI() {
    final double distanceKm = _distanceMeters / 1000;

    return Column(
      children: [
        // ==================================================
        // ACTIVITY TYPE (only editable before starting)
        // ==================================================
        if (_state == _TrackingState.idle) _buildTypeSelector(),

        // ==================================================
        // MAP
        // ==================================================
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final LatLng initial = _routePoints.isNotEmpty
                  ? _routePoints.first
                  : const LatLng(0, 0);

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initial,
                  zoom: 17,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _routePoints,
                    color: AppColors.primaryBlue,
                    width: 5,
                  ),
                },
                markers: _routePoints.isEmpty
                    ? {}
                    : {
                  Marker(
                    markerId: const MarkerId('start'),
                    position: _routePoints.first,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                },
              );
            },
          ),
        ),

        // ==================================================
        // LIVE STATS
        // ==================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statTile('Distance', '${distanceKm.toStringAsFixed(2)} km'),
                  _statTile('Time', _formatDuration(_elapsedSeconds)),
                  _statTile('Pace', _formatPace(distanceKm, _elapsedSeconds)),
                ],
              ),
              const SizedBox(height: 16),
              _buildControls(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _activityTypes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final type = _activityTypes[index];
            final isSelected = _selectedType == type;

            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.secondaryText,
                    fontSize: 13,
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.normalText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    switch (_state) {
      case _TrackingState.idle:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _startTracking,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Start Tracking',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );

      case _TrackingState.tracking:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _pauseTracking,
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text('Pause'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _stopTracking,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case _TrackingState.paused:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _resumeTracking,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _stopTracking,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case _TrackingState.finished:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveSession,
            icon: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? 'Saving...' : 'Save Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatPace(double distanceKm, int elapsedSeconds) {
    if (distanceKm <= 0 || elapsedSeconds <= 0) return '--:--';

    final double secondsPerKm = elapsedSeconds / distanceKm;
    final int minutes = (secondsPerKm ~/ 60);
    final int seconds = (secondsPerKm % 60).round();

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')} /km';
  }
}