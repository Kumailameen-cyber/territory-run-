import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  
  final mapContent = await File(mapScreenPath).readAsString();
  
  // Find start and end of _demoTerritories in map_screen.dart
  final tStartMarker = 'static const List<Map<String, dynamic>> _demoTerritories = [';
  final rStartMarker = 'static const List<LatLng> _demoRunTrail = [';
  
  int tStartIdx = mapContent.indexOf(tStartMarker);
  int rStartIdx = mapContent.indexOf(rStartMarker);
  int rEndIdx = mapContent.indexOf('];', rStartIdx) + 2;
  
  // Build minimal territories string
  final newTerritoriesRaw = '''
$tStartMarker
    {
      'name': "Zamzama Box",
      'owner': 'Runner A',
      'level': 3,
      'power': 76,
      'streak': 5,
      'lastDefended': '2h ago',
      'colorIndex': 1, // cyan
      'points': [
        LatLng(24.821196, 67.033299),
        LatLng(24.819812, 67.036890),
        LatLng(24.816655, 67.037140),
        LatLng(24.818405, 67.032617),
      ],
    },
  ];
''';

  final newRunTrailRaw = '''
$rStartMarker
    LatLng(24.823381, 67.032881),
    LatLng(24.821332, 67.034214),
    LatLng(24.818418, 67.039858),
  ];
''';

  String rewritten = mapContent.substring(0, tStartIdx) + 
                     newTerritoriesRaw + '\n\n  // Minimal active run trail\n  ' + 
                     newRunTrailRaw + '\n' +
                     mapContent.substring(rEndIdx);
  
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully injected minimal coordinates.');
}
