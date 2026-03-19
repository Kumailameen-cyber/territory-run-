import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final coordinatesPath = '../scripts/routes_large.txt';
  
  final mapContent = await File(mapScreenPath).readAsString();
  final coordsContent = await File(coordinatesPath).readAsString();
  
  // Extract chunks from coordsContent
  final parts = coordsContent.split('--- Ongoing Run Path ---');
  final territoryPointsStr = parts[0].split('--- Mazar to Nazimabad Loop ---')[1].trim();
  final runTrailPointsStr = parts[1].trim();
  
  // Find start and end of _demoTerritories in map_screen.dart
  final tStartMarker = 'static const List<Map<String, dynamic>> _demoTerritories = [';
  final rStartMarker = 'static const List<LatLng> _demoRunTrail = [';
  
  int tStartIdx = mapContent.indexOf(tStartMarker);
  int rStartIdx = mapContent.indexOf(rStartMarker);
  int rEndIdx = mapContent.indexOf('];', rStartIdx) + 2;
  
  // Build new territories string
  final newTerritoriesRaw = '''
$tStartMarker
    {
      'name': "The Mazar Loop",
      'owner': 'Runner A',
      'level': 6,
      'power': 95,
      'streak': 22,
      'lastDefended': '5m ago',
      'colorIndex': 2, // pink
$territoryPointsStr,
    },
  ];
''';

  final newRunTrailRaw = '''
$rStartMarker
$runTrailPointsStr;
''';

  String rewritten = mapContent.substring(0, tStartIdx) + 
                     newTerritoriesRaw + '\n\n  // Demo active run trail completely mapped to roads starting near Mazar-e-Quaid down to Nazimabad\n  ' + 
                     newRunTrailRaw + '\n' +
                     mapContent.substring(rEndIdx);
                     
  // Update camera initial position for the monumental route
  rewritten = rewritten.replaceFirst(
    'target: LatLng(24.8198, 67.0355),', 
    'target: LatLng(24.887, 67.035),'
  );
  rewritten = rewritten.replaceFirst(
    'zoom: 16,', 
    'zoom: 13.5,'
  );
  
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully safely injected monumental loop coordinates.');
}
