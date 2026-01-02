import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      
import '../models/aire.dart';
import '../services/storage_service.dart';
import '../services/osm_service.dart'; // Assurez-vous d'avoir créé ce fichier à l'étape précédente

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // On démarre avec une liste vide, on va la remplir via internet
  List<Aire> aires = []; 
  
  final StorageService storageService = StorageService();
  final OsmService osmService = OsmService(); // Notre nouveau service
  
  Set<String> visitedIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // On lance le chargement complet au démarrage
    loadData();
  }

  // C'est cette méthode qui fait tout le travail maintenant
  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      // 1. On récupère les aires depuis OpenStreetMap (Internet)
      final loadedAires = await osmService.fetchAires();
      
      // 2. On récupère vos visites depuis le téléphone (Mémoire)
      final ids = await storageService.getVisitedAires();

      setState(() {
        aires = loadedAires;
        visitedIds = ids;
        
        // 3. On croise les deux infos : qui est visité ?
        for (var aire in aires) {
          aire.visitee = visitedIds.contains(aire.id);
        }
        
        isLoading = false;
      });

      // Petit message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${aires.length} aires chargées !')),
        );
      }

    } catch (e) {
      print("Erreur : $e");
      setState(() => isLoading = false);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de chargement OSM. Vérifiez votre connexion.')),
        );
      }
    }
  }

  void toggleVisite(Aire aire) async {
    setState(() {
      aire.visitee = !aire.visitee;
      if (aire.visitee) {
        visitedIds.add(aire.id);
      } else {
        visitedIds.remove(aire.id);
      }
    });
    await storageService.saveVisitedAires(visitedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AireDex 🗺️')),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Récupération des aires via OSM..."),
                ],
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(46.6, 2.2), // Centré sur la France
                initialZoom: 6.0, // Zoom dézommé pour voir toute la France
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app_aires',
                ),
                MarkerLayer(
                  markers: aires.map((aire) {
                    return Marker(
                      point: LatLng(aire.latitude, aire.longitude),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(aire.nom),
                              content: Text(aire.visitee ? "Déjà visitée ✅" : "Pas encore visitée ❌"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    toggleVisite(aire);
                                    Navigator.pop(ctx);
                                  },
                                  child: Text(aire.visitee ? "Annuler visite" : "Marquer comme visité"),
                                )
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.location_on,
                          color: aire.visitee ? Colors.green : Colors.red,
                          size: 30, // Un peu plus petit car il y aura beaucoup de points
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}