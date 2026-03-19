import 'dart:convert';
import 'dart:io';

Future<void> fetchRoute(String name, List<List<double>> points) async {
  final coords = points.map((p) => '${p[0]},${p[1]}').join(';');
  // Use driving profile for large city roads to ensure it snaps to the major arteries shown in the screenshot
  final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$coords?geometries=geojson&overview=full');
  
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
  // Creating a massive loop matching the user's screenshot:
  // Starts near Mazar-e-Quaid/Jamshed Rd, goes north to Liaquatabad, west to Nazimabad, south via Lasbela back to start.
  await fetchRoute('Mazar to Nazimabad Loop', [
    [67.0427, 24.8744], // Near Mazar-e-Quaid / Jamshed Rd
    [67.0454, 24.8978], // Up Business Recorder Rd to Liaquatabad
    [67.0306, 24.9015], // Across to Nazimabad
    [67.0264, 24.8876], // Down through Lasbela
    [67.0427, 24.8744], // Back to Mazar-e-Quaid
  ]);

  await Future.delayed(Duration(seconds: 1));
  
  // A secondary route crossing through the middle for the ongoing run
  await fetchRoute('Ongoing Run Path', [
    [67.0306, 24.9015], // From Nazimabad
    [67.0350, 24.8850], // Cutting diagonally through the center
    [67.0427, 24.8744], // Ending at Mazar
  ]);

  exit(0);
}
