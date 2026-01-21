import 'package:flutter/material.dart';
import 'rute.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> locations = [
      {
        "name": "Gede - Pangrango",
        "height": "3019 mdpl",
        "lat": -6.7702,
        "lng": 106.9995,
        "gpx": "assets/gpx/gede.gpx",
      },
      {
        "name": "Rinjani",
        "height": "3726 mdpl",
        "lat": -8.4113,
        "lng": 116.4574,
        "gpx": "assets/gpx/rinjani.gpx",
      },
      {
        "name": "Semeru",
        "height": "3676 mdpl",
        "lat": -8.1081,
        "lng": 112.9226,
        "gpx": "assets/gpx/semeru.gpx",
      },
      {
        "name": "Ciremai",
        "height": "3078 mdpl",
        "lat": -6.8924,
        "lng": 108.4076,
        "gpx": "assets/gpx/ciremai.gpx",
      },
      {
        "name": "Slamet",
        "height": "3428 mdpl",
        "lat": -7.2429,
        "lng": 109.2086,
        "gpx": "assets/gpx/slamet.gpx",
      },
      {
        "name": "Sumbing",
        "height": "3371 mdpl",
        "lat": -7.3840,
        "lng": 110.0704,
        "gpx": "assets/gpx/sumbing.gpx",
      },
      {
        "name": "Sindoro",
        "height": "3153 mdpl",
        "lat": -7.3012,
        "lng": 109.9926,
        "gpx": "assets/gpx/sindoro.gpx",
      },
      {
        "name": "Lawu",
        "height": "3265 mdpl",
        "lat": -7.6275,
        "lng": 111.1940,
        "gpx": "assets/gpx/lawu.gpx",
      },
      {
        "name": "Argopuro",
        "height": "3088 mdpl",
        "lat": -7.9763,
        "lng": 113.5165,
        "gpx": "assets/gpx/argopuro.gpx",
      },
      {
        "name": "Malabar",
        "height": "2343 mdpl",
        "lat": -7.1357,
        "lng": 107.6572,
        "gpx": "assets/gpx/malabar.gpx",
      },
      {
        "name": "Cikuray",
        "height": "2821 mdpl",
        "lat": -7.3199,
        "lng": 107.8270,
        "gpx": "assets/gpx/cikuray.gpx",
      },
      {
        "name": "Salak",
        "height": "2211 mdpl",
        "lat": -6.7167,
        "lng": 106.7333,
        "gpx": "assets/gpx/salak.gpx",
      },
      {
        "name": "Manglayang",
        "height": "1818 mdpl",
        "lat": -6.8747,
        "lng": 107.7283,
        "gpx": "assets/gpx/manglayang.gpx",
      },
      {
        "name": "Burangrang",
        "height": "2050 mdpl",
        "lat": -6.7794,
        "lng": 107.5939,
        "gpx": "assets/gpx/burangrang.gpx",
      },
      {
        "name": "Merbabu",
        "height": "3145 mdpl",
        "lat": -7.4556,
        "lng": 110.4406,
        "gpx": "assets/gpx/merbabu.gpx",
      },
      {
        "name": "Prau",
        "height": "2565 mdpl",
        "lat": -7.1933,
        "lng": 109.9222,
        "gpx": "assets/gpx/prau.gpx",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            padding:
                const EdgeInsets.only(top: 30, bottom: 5, left: 15, right: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.terrain, color: Colors.orange),
                ),
                const Expanded(
                  child: Text(
                    "Daftar Lokasi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.white),
              ],
            ),
          ),

          // LIST GUNUNG
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final item = locations[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RutePage(
                          namaGunung: item['name'],
                          lat: item['lat'],
                          lng: item['lng'],
                          gpxPath: item['gpx'],
                        ),
                      ),
                    );
                  },
                  child: _buildLocationCard(
                    item['name'],
                    item['height'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String name, String height) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(height),
        ],
      ),
    );
  }
}
