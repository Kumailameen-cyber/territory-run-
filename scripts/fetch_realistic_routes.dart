import 'dart:convert';
import 'dart:io';

Future<void> fetchRoute(String name, List<List<double>> points) async {
  final coords = points.map((p) => '${p[0]},${p[1]}').join(';');
  // Use 'foot' profile for realistic runner walking/running paths
  final url = Uri.parse('http://router.project-osrm.org/route/v1/foot/$coords?geometries=geojson&overview=full');
  
  final client = HttpClient();
  final request = await client.getUrl(url);
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  
  final data = json.decode(body);
  if (data['code'] == 'Ok') {
    final coordsList = data['routes'][0]['geometry']['coordinates'] as List;
    print('--- $name ---');
    print('  \'points\': [');
    for (var c in coordsList) {
      print('    LatLng(${c[1]}, ${c[0]}),');
    }
    print('  ],');
  } else {
    print('Error for $name: $body');
  }
}

void main() async {
  // 1. Frere Hall / Bagh-e-Jinnah Loop (Approx 1.5 km run)
  await fetchRoute('Frere Hall Loop', [
    [67.0326, 24.8488], // Fatima Jinnah Rd / Abdullah Haroon intersection
    [67.0345, 24.8465], // South along Abdullah Haroon Rd
    [67.0320, 24.8447], // West along civil lines
    [67.0305, 24.8475], // North along Fatima Jinnah Rd
    [67.0326, 24.8488], // Back to start
  ]);

  await Future.delayed(Duration(seconds: 1));

  // 2. Zamzama Park & Surrounds (Approx 1 km run)
  await fetchRoute('Zamzama Park Circuit', [
    [67.0327, 24.8184], 
    [67.0366, 24.8164], 
    [67.0353, 24.8142], 
    [67.0315, 24.8160], 
    [67.0327, 24.8184],
  ]);

  await Future.delayed(Duration(seconds: 1));

  // 3. Hill Park Loop (Approx 1.5 km run in PECHS)
  await fetchRoute('Hill Park Circuit', [
    [67.0733, 24.8690], // North entrance
    [67.0760, 24.8670], // East curve
    [67.0730, 24.8640], // South curve
    [67.0705, 24.8665], // West curve
    [67.0733, 24.8690], // Back to start
  ]);

  await Future.delayed(Duration(seconds: 1));

  // Ongoing Run Path (Connecting Zamzama Commercial to the Park)
  await fetchRoute('Ongoing Run Path', [
    [67.0290, 24.8210], // Near Do Talwar / Clifton
    [67.0335, 24.8180], // Heading towards park
    [67.0355, 24.8190], // Running along the commercial street
  ]);

  exit(0);
}
