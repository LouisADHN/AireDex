class Aire {
  final String id;
  final String nom;
  final double latitude;
  final double longitude;
  bool visitee;

  Aire({
    required this.id,
    required this.nom,
    required this.latitude,
    required this.longitude,
    this.visitee = false,
  });
}