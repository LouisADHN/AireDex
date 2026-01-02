class Aire {
  final String id;
  final String nom;
  bool visitee;

  Aire({
    required this.id,
    required this.nom,
    this.visitee = false,
  });
}