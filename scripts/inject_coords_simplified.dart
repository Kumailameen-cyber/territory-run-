import 'dart:io';

// Function to significantly thin out the coordinates to preventing WebGL crashing
String simplifyPoints(String rawPoints, int keepEvery) {
  final lines = rawPoints.split('\n');
  final simplified = <String>[];
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;
    // Always keep the first and last point to close the loop, plus every Nth point
    if (i == 0 || i == lines.length - 1 || i % keepEvery == 0) {
      simplified.add(lines[i]);
    }
  }
  return simplified.join('\n');
}

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final coordinatesPath = '../scripts/routes_realistic.txt';
  
  final mapContent = await File(mapScreenPath).readAsString();
  final coordsContent = await File(coordinatesPath).readAsString();
  
  // Extract chunks from coordsContent
  final parts = coordsContent.split('---');
  
  // Extract and massively simplify the coordinate arrays to save WebGL memory
  String frereRaw = parts[2].split('\'points\': [')[1].split('],')[0].trim();
  String frerePoints = simplifyPoints(frereRaw, 4); // Keep 1 in 4 points
  
  String zamzamaRaw = parts[4].split('\'points\': [')[1].split('],')[0].trim();
  String zamzamaPoints = simplifyPoints(zamzamaRaw, 3); // Zamzama is smaller, keep 1 in 3
  
  String hillParkRaw = parts[6].split('\'points\': [')[1].split('],')[0].trim();
  String hillParkPoints = simplifyPoints(hillParkRaw, 4); 

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
    'target: LatLng(24.8198, 67.0355),', 
    'target: LatLng(24.8155, 67.0345),'
  );
  rewritten = rewritten.replaceFirst(
    'zoom: 16,', 
    'zoom: 15.5,' // Zoomed in closer for a realistic runner's view
  );
                             
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully safely injected memory-optimized realistic runner loops.');
}
