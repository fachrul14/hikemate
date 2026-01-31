import 'package:flutter/material.dart';
import 'rute.dart';
import 'package:hikemate/widgets/app_header.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // <-- ditambahkan
  List<Map<String, dynamic>> filteredLocations = [];

  final List<Map<String, dynamic>> locations = [
    {
      "name": "Gede - Pangrango",
      "height": "3019 mdpl",
      "lat": -6.7702,
      "lng": 106.9995,
      "gpx": "assets/gpx/gede.gpx"
    },
    {
      "name": "Rinjani",
      "height": "3726 mdpl",
      "lat": -8.4113,
      "lng": 116.4574,
      "gpx": "assets/gpx/rinjani.gpx"
    },
    {
      "name": "Semeru",
      "height": "3676 mdpl",
      "lat": -8.1081,
      "lng": 112.9226,
      "gpx": "assets/gpx/semeru.gpx"
    },
    {
      "name": "Ciremai",
      "height": "3078 mdpl",
      "lat": -6.8924,
      "lng": 108.4076,
      "gpx": "assets/gpx/ciremai.gpx"
    },
    {
      "name": "Slamet",
      "height": "3428 mdpl",
      "lat": -7.2429,
      "lng": 109.2086,
      "gpx": "assets/gpx/slamet.gpx"
    },
    {
      "name": "Sumbing",
      "height": "3371 mdpl",
      "lat": -7.3840,
      "lng": 110.0704,
      "gpx": "assets/gpx/sumbing.gpx"
    },
    {
      "name": "Sindoro",
      "height": "3153 mdpl",
      "lat": -7.3012,
      "lng": 109.9926,
      "gpx": "assets/gpx/sindoro.gpx"
    },
    {
      "name": "Lawu",
      "height": "3265 mdpl",
      "lat": -7.6275,
      "lng": 111.1940,
      "gpx": "assets/gpx/lawu.gpx"
    },
    {
      "name": "Argopuro",
      "height": "3088 mdpl",
      "lat": -7.9763,
      "lng": 113.5165,
      "gpx": "assets/gpx/argopuro.gpx"
    },
    {
      "name": "Malabar",
      "height": "2343 mdpl",
      "lat": -7.1357,
      "lng": 107.6572,
      "gpx": "assets/gpx/malabar.gpx"
    },
    {
      "name": "Cikuray",
      "height": "2821 mdpl",
      "lat": -7.3199,
      "lng": 107.8270,
      "gpx": "assets/gpx/cikuray.gpx"
    },
    {
      "name": "Salak",
      "height": "2211 mdpl",
      "lat": -6.7167,
      "lng": 106.7333,
      "gpx": "assets/gpx/salak.gpx"
    },
    {
      "name": "Manglayang",
      "height": "1818 mdpl",
      "lat": -6.8747,
      "lng": 107.7283,
      "gpx": "assets/gpx/manglayang.gpx"
    },
    {
      "name": "Burangrang",
      "height": "2050 mdpl",
      "lat": -6.7794,
      "lng": 107.5939,
      "gpx": "assets/gpx/burangrang.gpx"
    },
    {
      "name": "Merbabu",
      "height": "3145 mdpl",
      "lat": -7.4556,
      "lng": 110.4406,
      "gpx": "assets/gpx/merbabu.gpx"
    },
    {
      "name": "Prau",
      "height": "2565 mdpl",
      "lat": -7.1933,
      "lng": 109.9222,
      "gpx": "assets/gpx/prau.gpx"
    },
    {
      "name": "Bukit Tunggul",
      "height": "1,200 mdpl",
      "lat": -6.8500,
      "lng": 107.6500,
      "gpx": "assets/gpx/bukit_tunggul.gpx"
    },
    {
      "name": "Galunggung",
      "height": "2,168 mdpl",
      "lat": -7.2500,
      "lng": 108.0200,
      "gpx": "assets/gpx/galunggung.gpx"
    },
    {
      "name": "Halimun",
      "height": "1,929 mdpl",
      "lat": -6.7000,
      "lng": 106.9000,
      "gpx": "assets/gpx/halimun.gpx"
    },
    {
      "name": "Patuha",
      "height": "2,434 mdpl",
      "lat": -7.3000,
      "lng": 107.3000,
      "gpx": "assets/gpx/patuha.gpx"
    },
    {
      "name": "Andong",
      "height": "1,726 mdpl",
      "lat": -7.5000,
      "lng": 110.3000,
      "gpx": "assets/gpx/andong.gpx"
    },
    {
      "name": "Kembang",
      "height": "1,789 mdpl",
      "lat": -7.3500,
      "lng": 110.3000,
      "gpx": "assets/gpx/kembang.gpx"
    },
    {
      "name": "Merapi",
      "height": "2,930 mdpl",
      "lat": -7.5400,
      "lng": 110.4420,
      "gpx": "assets/gpx/merapi.gpx"
    },
    {
      "name": "Telomoyo",
      "height": "1,894 mdpl",
      "lat": -7.4500,
      "lng": 110.4000,
      "gpx": "assets/gpx/telomoyo.gpx"
    },
    {
      "name": "Ungaran",
      "height": "2,050 mdpl",
      "lat": -7.2000,
      "lng": 110.4000,
      "gpx": "assets/gpx/ungaran.gpx"
    },
    {
      "name": "Raung",
      "height": "3,332 mdpl",
      "lat": -7.9400,
      "lng": 114.0300,
      "gpx": "assets/gpx/raung.gpx"
    },
    {
      "name": "Kelud",
      "height": "1,731 mdpl",
      "lat": -7.9200,
      "lng": 112.3300,
      "gpx": "assets/gpx/kelud.gpx"
    },
    {
      "name": "Agung",
      "height": "3,031 mdpl",
      "lat": -8.3400,
      "lng": 115.5100,
      "gpx": "assets/gpx/agung.gpx"
    },
    {
      "name": "Tambora",
      "height": "2,850 mdpl",
      "lat": -8.2500,
      "lng": 118.0000,
      "gpx": "assets/gpx/tambora.gpx"
    },
    {
      "name": "Kerinci",
      "height": "3,805 mdpl",
      "lat": -2.0500,
      "lng": 101.2700,
      "gpx": "assets/gpx/kerinci.gpx"
    },
    {
      "name": "Sinabung",
      "height": "2,460 mdpl",
      "lat": 3.1700,
      "lng": 98.3920,
      "gpx": "assets/gpx/sinabung.gpx"
    },
    {
      "name": "Leuser",
      "height": "3,119 mdpl",
      "lat": 3.8867,
      "lng": 97.4544,
      "gpx": "assets/gpx/leuser.gpx"
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredLocations = locations;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredLocations = locations.where((loc) {
          return loc['name'].toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose(); // <-- dispose juga
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          const AppHeader(
            title: "Daftar Lokasi",
          ),
          // SEARCH FIELD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari gunung...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              ),
            ),
          ),

          // LIST GUNUNG DENGAN SCROLLBAR
          Expanded(
            child: Scrollbar(
              controller: _scrollController, // <-- controller ditambahkan
              thumbVisibility: true,
              radius: const Radius.circular(10),
              child: ListView.builder(
                controller:
                    _scrollController, // <-- controller dipakai juga di ListView
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final item = filteredLocations[index];

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
                    child: _buildLocationCard(item['name'], item['height']),
                  );
                },
              ),
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
