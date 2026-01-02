import 'package:flutter/material.dart';
import '../models/aire.dart';
import '../services/storage_service.dart';


class HomeScreen extends StatefulWidget{

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Aire> aires = [
    Aire(id: '1', nom: 'Aire de Nancy'),
    Aire(id: '2', nom: 'Aire de Troyes'),
    Aire(id: '3', nom: 'Aire du Metz'),
  ];
  final StorageService storageService = StorageService();
  Set<String> visitedIds = {};
  bool isLoading = true;



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
      appBar: AppBar(
        title: const Text('AireDex 🚗'),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
          itemCount: aires.length,
          itemBuilder: (context, index) {
            final aire = aires[index];

            return ListTile(
              leading: Icon(
                aire.visitee
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: aire.visitee ? Colors.green : Colors.grey,
              ),
              title: Text(aire.nom),
              trailing: TextButton(
                onPressed: () => toggleVisite(aire),
                child: Text(aire.visitee ? 'Visité' : 'Marquer'),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadVisitedAires();
  }

  Future<void> loadVisitedAires() async {
  final ids = await storageService.getVisitedAires();

  setState(() {
    visitedIds = ids;

    for (var aire in aires) {
      aire.visitee = visitedIds.contains(aire.id);
    }

    isLoading = false;
  });
}


}