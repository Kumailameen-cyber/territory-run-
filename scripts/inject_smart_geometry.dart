import 'dart:io';
import 'dart:math';

// Calculate distance between two LatLng points in meters to intelligently decimate points
double coordinateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p) / 2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)) * 1000;
}

String optimizePoints(String rawPoints, double minDistanceMeters) {
  final lines = rawPoints.split('\n');
  final optimized = <String>[];
  
  double? lastLat;
  double? lastLng;
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    
    // Always keep first and last point
    if (i == 0 || i == lines.length - 1) {
      optimized.add(line);
      continue;
    }
    
    // Parse LatLng(24.818394, 67.032699),
    try {
      final parts = line.split('LatLng(')[1].split(')')[0].split(', ');
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      
      if (lastLat == null || lastLng == null) {
        optimized.add(line);
        lastLat = lat;
        lastLng = lng;
        continue;
      }
      
      final dist = coordinateDistance(lastLat, lastLng, lat, lng);
      if (dist >= minDistanceMeters) {
        optimized.add(line);
        lastLat = lat;
        lastLng = lng;
      }
    } catch (e) {
      // If parsing fails, just keep the line to be safe
      optimized.add(line);
    }
  }
  
  return optimized.join('\n');
}

void main() async {
  final mapScreenPath = 'screens/map/map_screen.dart';
  final coordinatesPath = '../scripts/routes_realistic.txt';
  
  final mapContent = await File(mapScreenPath).readAsString();
  final coordsContent = await File(coordinatesPath).readAsString();
  
  final parts = coordsContent.split('---');
  
  // Extract and intelligently optimize the coordinate arrays.
  // We want to keep points if they are at least 15 meters apart. This is tight enough
  // to perfectly capture the curves of roads (like a real runner tracker) but drops redundant
  // points on straightaways to save WebGL memory.
  String frereRaw = parts[2].split('\'points\': [')[1].split('],')[0].trim();
  String frerePoints = optimizePoints(frereRaw, 15.0); 
  
  String zamzamaRaw = parts[4].split('\'points\': [')[1].split('],')[0].trim();
  String zamzamaPoints = optimizePoints(zamzamaRaw, 10.0); // 10m precision for tight local grids
  
  String hillParkRaw = parts[6].split('\'points\': [')[1].split('],')[0].trim();
  String hillParkPoints = optimizePoints(hillParkRaw, 15.0); 

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

  // Active run nicely hugging Zamzama Blvd curves
  static const List<LatLng> _demoRunTrail = [
    LatLng(24.814397, 67.034777),
    LatLng(24.814168, 67.033915),
    LatLng(24.814374, 67.033839),
    LatLng(24.815425, 67.033462),
    LatLng(24.815583, 67.033413),
    LatLng(24.816258, 67.033483),
    LatLng(24.817058, 67.033586),
    LatLng(24.817161, 67.032854),
    LatLng(24.817215, 67.032476),
    LatLng(24.817265, 67.032145),
    LatLng(24.817302, 67.031864),
    LatLng(24.817386, 67.031275),
    LatLng(24.816973, 67.030939),
    LatLng(24.816875, 67.030989),
    LatLng(24.816755, 67.031055),
    LatLng(24.816515, 67.031183),
  ];

  ''';

  String rewritten = mapContent.substring(0, tStartIdx) + newCode + mapContent.substring(rEndIdx);
                             
  await File(mapScreenPath).writeAsString(rewritten);
  print('Successfully injected geometrically accurate but memory-optimized routes.');
}
