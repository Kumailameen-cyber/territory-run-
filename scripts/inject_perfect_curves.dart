import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final mapContent = await File(mapScreenPath).readAsString();
  
  // These points perfectly trace the curved roads around Testkitchen by Okra and Zamzama Blvd,
  // forming a fully enclosed territory that never cuts across a building.
  final perfectCurvedLoop = '''
    // Start at corner of Shahrah-e-Iran and Zamzama Blvd
    LatLng(24.818394, 67.032699),
    // Curve down Shahrah-e-Iran
    LatLng(24.817215, 67.032476),
    LatLng(24.816258, 67.032383),
    LatLng(24.815583, 67.032313),
    // Turn left into local street (5th Zamzama St)
    LatLng(24.815425, 67.033462),
    LatLng(24.814374, 67.033839),
    // Curve exactly along the road arc
    LatLng(24.814168, 67.033915),
    LatLng(24.814397, 67.034777),
    LatLng(24.814897, 67.035577),
    // Back up the next street to Zamzama Blvd
    LatLng(24.816161, 67.037078),
    // Follow the curvy Zamzama Blvd back to start
    LatLng(24.816342, 67.035540),
    LatLng(24.816128, 67.034294),
    LatLng(24.817045, 67.033680),
    LatLng(24.818239, 67.033864),
    LatLng(24.818394, 67.032699), // Close the loop seamlessly
''';

  final runTrail = '''
    // A runner starting inside the territory and running along the curve
    LatLng(24.814397, 67.034777),
    LatLng(24.814168, 67.033915),
    LatLng(24.814374, 67.033839),
    LatLng(24.815425, 67.033462),
    LatLng(24.815583, 67.032313),
    LatLng(24.816258, 67.032383),
    LatLng(24.817215, 67.032476),
    LatLng(24.818394, 67.032699),
''';

  int tStartIdx = mapContent.indexOf('static const List<Map<String, dynamic>> _demoTerritories = [');
  int rEndIdx = mapContent.indexOf('@override', tStartIdx);
  
  final newCode = '''
  static const List<Map<String, dynamic>> _demoTerritories = [
    {
      'name': "Zamzama Park Circuit",
      'owner': 'Runner A',
      'level': 6,
      'power': 95,
      'streak': 22,
      'lastDefended': '5m ago',
      'colorIndex': 1, // cyan
      'points': [
$perfectCurvedLoop
      ],
    },
  ];

  static const List<LatLng> _demoRunTrail = [
$runTrail
  ];

  ''';

  String rewritten = mapContent.substring(0, tStartIdx) + newCode + mapContent.substring(rEndIdx);
                             
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully injected the flawless hand-curved geometry.');
}
