import 'dart:convert';
import 'dart:io';

Future<void> fetchRoute(String name, List<List<double>> points) async {
  final coords = points.map((p) => '${p[0]},${p[1]}').join(';');
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
  await fetchRoute('Zamzama Block 1', [
    [67.033325, 24.821369],
    [67.036878, 24.819626],
    [67.035349, 24.820791],
    [67.031825, 24.822469],
    [67.033325, 24.821369],
  ]);

  await Future.delayed(Duration(seconds: 1));

  await fetchRoute('Zamzama Block 3', [
    [67.038166, 24.818982],
    [67.039806, 24.818442],
    [67.038105, 24.819268],
    [67.036686, 24.820061],
    [67.038166, 24.818982],
  ]);

  await Future.delayed(Duration(seconds: 1));

  await fetchRoute('Zamzama Park', [
    [67.0326, 24.8183], 
    [67.0366, 24.8164], 
    [67.0353, 24.8142], 
    [67.0315, 24.8160], 
    [67.0326, 24.8183],
  ]);

  await Future.delayed(Duration(seconds: 1));

  await fetchRoute('Ongoing Run Path', [
    [67.0325, 24.8235],
    [67.0305, 24.8225],
    [67.0323, 24.8218],
    [67.0398, 24.8184],
  ]);
  
  exit(0);
}
