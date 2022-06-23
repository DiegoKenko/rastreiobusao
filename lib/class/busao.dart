class Busao {
  String? placa;
  String? id;
  double? latitude;
  double? longitude;
  double? heading;

  Busao.fromMap(Map<String, dynamic> data) : placa = data["placa"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'placa': id,
        'latitude': id,
        'longitude': id,
      };
}
