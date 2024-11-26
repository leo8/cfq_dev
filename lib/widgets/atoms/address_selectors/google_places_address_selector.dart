import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import '../../../utils/styles/colors.dart';
import '../../../utils/styles/icons.dart';
import '../../../utils/styles/text_styles.dart';
import '../texts/bordered_icon_text_field.dart';
import '../../../utils/logger.dart';
import '../../../utils/styles/string.dart';

class GooglePlacesAddressSelector extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final CustomIcon icon;
  final Function(PlaceData) onPlaceSelected;

  const GooglePlacesAddressSelector({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.onPlaceSelected,
  });

  @override
  State<GooglePlacesAddressSelector> createState() =>
      _GooglePlacesAddressSelectorState();
}

class _GooglePlacesAddressSelectorState
    extends State<GooglePlacesAddressSelector> {
  late final FlutterGooglePlacesSdk _places;
  List<AutocompletePrediction>? _predictions;
  bool _showPredictions = false;
  bool get showPredictions => _showPredictions;
  bool _ignoreTextChange = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    initPlaces();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _removeOverlay();
    super.dispose();
  }

  Future<void> initPlaces() async {
    try {
      _places = FlutterGooglePlacesSdk(
        'AIzaSyA65gP0gnZAjqrrSkQTZB60svG86LJqMDE',
      );
      final isInitialized = await _places.isInitialized();
      debugPrint('Places SDK initialized: $isInitialized');

      // Test the API key with a simple query
      await _places.findAutocompletePredictions('test');
      debugPrint('Places API key validated successfully');
    } catch (e) {
      debugPrint('Error initializing Places SDK: $e');
      // Show error in UI if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error initializing location services. Please try again later.'),
          ),
        );
      }
    }
  }

  void _onSearchChanged() async {
    if (_ignoreTextChange || widget.controller.text.isEmpty) {
      return;
    }

    try {
      final result = await _places.findAutocompletePredictions(
        widget.controller.text,
        countries: ['fr'],
      );

      if (!mounted) return;

      setState(() {
        _predictions = result.predictions;
        _showPredictions = true;
      });
      _showOverlay();
    } catch (e) {
      AppLogger.debug('Error fetching predictions: $e');
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible layer to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Predictions list
          Positioned(
            top: offset.dy + size.height,
            left: offset.dx,
            width: size.width,
            child: Material(
              elevation: 4,
              color: CustomColor.customBlack,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _predictions?.length ?? 0,
                itemBuilder: (context, index) {
                  final prediction = _predictions![index];
                  return ListTile(
                    title: Text(
                      prediction.primaryText,
                      style: CustomTextStyle.body1,
                    ),
                    subtitle: Text(
                      prediction.secondaryText,
                      style: CustomTextStyle.body2
                          .copyWith(color: CustomColor.grey),
                    ),
                    onTap: () => _onPredictionSelected(prediction),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _onPredictionSelected(AutocompletePrediction prediction) async {
    setState(() {
      _showPredictions = false;
      _predictions = null;
    });
    _removeOverlay();

    try {
      final placeResult = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Location, PlaceField.Address],
      );

      if (!mounted) return;

      final place = placeResult.place;
      if (place != null && place.address != null) {
        _ignoreTextChange = true;
        widget.controller.text = place.address!;
        widget.onPlaceSelected(PlaceData(
          address: place.address!,
          latitude: place.latLng?.lat,
          longitude: place.latLng?.lng,
        ));
        _ignoreTextChange = false;
      }
    } catch (e) {
      AppLogger.debug('Error fetching place details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(CustomString.someErrorOccurred),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BorderedIconTextField(
      icon: widget.icon,
      controller: widget.controller,
      hintText: widget.hintText,
      onTap: null,
    );
  }
}

class PlaceData {
  final String address;
  final double? latitude;
  final double? longitude;

  PlaceData({
    required this.address,
    this.latitude,
    this.longitude,
  });
}
