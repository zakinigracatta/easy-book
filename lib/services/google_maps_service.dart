import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business_model.dart';

enum MapsTravelMode { driving, walking }

class GoogleMapsService {
  const GoogleMapsService();

  Future<void> openDirections(
    BusinessModel business, {
    MapsTravelMode travelMode = MapsTravelMode.driving,
  }) async {
    final destination = _destinationFor(business);
    if (destination == null) {
      throw StateError(
        'This business does not have a valid location or address yet.',
      );
    }

    final mode = switch (travelMode) {
      MapsTravelMode.driving => 'driving',
      MapsTravelMode.walking => 'walking',
    };

    // Android: prefer the native Google Maps navigation intent. This opens
    // Google Maps directly when it is installed and starts with the selected
    // destination/travel mode.
    final nativeUri = Uri.parse(
      'google.navigation:q=${Uri.encodeComponent(destination)}&mode=${travelMode == MapsTravelMode.walking ? 'w' : 'd'}',
    );

    try {
      final nativeOpened = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (nativeOpened) return;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('GOOGLE_MAPS_NATIVE_LAUNCH_FAILED: $error');
      }
    }

    // Universal Google Maps URL fallback. It works on Android/iOS/web and can
    // still hand off to Google Maps when the operating system supports it.
    final webUri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      <String, String>{
        'api': '1',
        'destination': destination,
        'travelmode': mode,
      },
    );

    final opened = await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw StateError('Google Maps could not be opened on this device.');
    }
  }

  String? _destinationFor(BusinessModel business) {
    final hasCoordinates = business.latitude.abs() <= 90 &&
        business.longitude.abs() <= 180 &&
        business.latitude != 0 &&
        business.longitude != 0;

    if (hasCoordinates) {
      return '${business.latitude},${business.longitude}';
    }

    final address = business.address.trim();
    if (address.isNotEmpty) return address;

    return null;
  }
}
