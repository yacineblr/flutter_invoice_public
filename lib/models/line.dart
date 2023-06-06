class Line {
  String description;
  String prixHt;
  String qte;

  Line({required this.description, required this.prixHt, required this.qte});

  @override
  String toString() {
    return 'Line(description: $description, prixHt: $prixHt, qte: $qte)';
  }

  factory Line.fromJson(Map<String, dynamic> json) => Line(
        description: json['description'] as String,
        prixHt: json['prix_ht'] as String,
        qte: json['qte'] as String,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'prix_ht': prixHt,
        'qte': qte,
      };
}
