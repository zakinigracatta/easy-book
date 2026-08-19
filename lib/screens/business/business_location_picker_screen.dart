import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class BusinessLocationArgs {
  const BusinessLocationArgs({this.latitude = 0, this.longitude = 0});

  final double latitude;
  final double longitude;
}

class BusinessLocationSelection {
  const BusinessLocationSelection({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class BusinessLocationPickerScreen extends StatefulWidget {
  const BusinessLocationPickerScreen({
    super.key,
    this.initialLatitude = 0,
    this.initialLongitude = 0,
  });

  final double initialLatitude;
  final double initialLongitude;

  @override
  State<BusinessLocationPickerScreen> createState() =>
      _BusinessLocationPickerScreenState();
}

class _BusinessLocationPickerScreenState
    extends State<BusinessLocationPickerScreen> {
  static const _dubai = LatLng(25.2048, 55.2708);

  GoogleMapController? _controller;
  late LatLng _selected;
  bool _locationPermissionGranted = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    final hasSavedLocation =
        widget.initialLatitude != 0 || widget.initialLongitude != 0;
    _selected = hasSavedLocation
        ? LatLng(widget.initialLatitude, widget.initialLongitude)
        : _dubai;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Precise Business Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 16),
            onMapCreated: (controller) => _controller = controller,
            onCameraMove: (position) => _selected = position.target,
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 38),
                child: Icon(
                  Icons.location_pin,
                  size: 54,
                  color: AppColors.error,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              color: AppColors.cardDark,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded,
                        color: AppColors.primaryLight),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Move the map until the pin is exactly on the salon entrance.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 142,
            child: FloatingActionButton.small(
              heroTag: 'current-location',
              backgroundColor: AppColors.cardDark,
              onPressed: _locating ? null : _useCurrentLocation,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded,
                      color: AppColors.primaryLight),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  context.pop(
                    BusinessLocationSelection(
                      latitude: _selected.latitude,
                      longitude: _selected.longitude,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text(
                  'Confirm This Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        throw StateError('Location services are disabled on this device.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required to use your position.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final target = LatLng(position.latitude, position.longitude);
      _selected = target;
      _locationPermissionGranted = true;
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 18),
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }
}
