import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final coordinatesPath = '../scripts/routes_large.txt';
  
  final mapContent = await File(mapScreenPath).readAsString();
  final coordsContent = await File(coordinatesPath).readAsString();
  
  // Extract chunks from coordsContent
  final parts = coordsContent.split('--- Ongoing Run Path ---');
  final territoryPointsStr = parts[0].split('--- Mazar to Nazimabad Loop ---')[1].trim();
  final runTrailPointsStrRaw = parts[1].trim();

  // Strip out " 'points': [" and trailing "]," from the extracted segments to avoid duplicate syntax
  String territoryPointsClean = territoryPointsStr
      .replaceAll('\'points\': [', '')
      .replaceAll('],', ']')
      .trim();

  if (!territoryPointsClean.endsWith(']')) {
     territoryPointsClean += ']';
  }

  String runTrailPointsClean = runTrailPointsStrRaw
      .replaceAll('\'points\': [', '')
      .replaceAll('],', ']')
      .trim();

  if (!runTrailPointsClean.endsWith(']')) {
     runTrailPointsClean += ']';
  }
  
  // Clean up any remaining trailing brackets to just have the raw LatLngs
  territoryPointsClean = territoryPointsClean.replaceAll(']', '').trim();
  runTrailPointsClean = runTrailPointsClean.replaceAll(']', '').trim();

  int tStartIdx = mapContent.indexOf('static const List<Map<String, dynamic>> _demoTerritories = [');
  int rEndIdx = mapContent.indexOf('@override', tStartIdx);
  
  final newCode = '''
  static const List<Map<String, dynamic>> _demoTerritories = [
    {
      'name': "The Mazar Loop",
      'owner': 'Runner A',
      'level': 6,
      'power': 95,
      'streak': 22,
      'lastDefended': '5m ago',
      'colorIndex': 2, // pink
      'points': [
$territoryPointsClean
      ],
    },
  ];

  static const List<LatLng> _demoRunTrail = [
$runTrailPointsClean
  ];

  ''';

  String rewritten = mapContent.substring(0, tStartIdx) + newCode + mapContent.substring(rEndIdx);
                             
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully generated valid dart code injected.');
}
