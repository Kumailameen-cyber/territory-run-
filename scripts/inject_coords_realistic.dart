import 'dart:io';

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final coordinatesPath = '../scripts/routes_realistic.txt';
  
  final mapContent = await File(mapScreenPath).readAsString();
  final coordsContent = await File(coordinatesPath).readAsString();
  
  // Extract chunks from coordsContent
  final parts = coordsContent.split('---');
  
  String frerePoints = parts[2].split('\'points\': [')[1].split('],')[0].trim();
  String zamzamaPoints = parts[4].split('\'points\': [')[1].split('],')[0].trim();
  String hillParkPoints = parts[6].split('\'points\': [')[1].split('],')[0].trim();

  int tStartIdx = mapContent.indexOf('static const List<Map<String, dynamic>> _demoTerritories = [');
  int rEndIdx = mapContent.indexOf('@override', tStartIdx);
  
  final newCode = '''
  static const List<Map<String, dynamic>> _demoTerritories = [
    {
      'name': "Frere Hall Sprint",
      'owner': 'Runner B',
      'level': 4,
      'power': 85,
      'streak': 14,
      'lastDefended': '1h ago',
      'colorIndex': 1, // cyan
      'points': [
$frerePoints
      ],
    },
    {
      'name': "Zamzama Park Circuit",
      'owner': 'Runner A',
      'level': 6,
      'power': 95,
      'streak': 22,
      'lastDefended': '5m ago',
      'colorIndex': 2, // pink
      'points': [
$zamzamaPoints
      ],
    },
    {
      'name': "Hill Park Loop",
      'owner': 'You',
      'level': 3,
      'power': 78,
      'streak': 5,
      'lastDefended': '2h ago',
      'colorIndex': 0, // green
      'points': [
$hillParkPoints
      ],
    },
  ];

  static const List<LatLng> _demoRunTrail = [
$zamzamaPoints
  ];

  ''';

  String rewritten = mapContent.substring(0, tStartIdx) + newCode + mapContent.substring(rEndIdx);
  
  // Update camera initial position to focus closely on Zamzama Park
  rewritten = rewritten.replaceFirst(
    'target: LatLng(24.887, 67.035),', 
    'target: LatLng(24.8155, 67.0345),'
  );
  rewritten = rewritten.replaceFirst(
    'zoom: 13.5,', 
    'zoom: 15.5,' // Zoomed in closer for a realistic runner's view
  );
                             
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully safely injected realistic runner loops.');
}
