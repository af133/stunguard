class UserEntity {
  final String id;
  final String name;
  final String? nik;
  final String phone;
  final String posyanduName;
  final String workArea;
  final String role; // 'kader' or 'orang_tua'

  UserEntity({
    required this.id,
    required this.name,
    this.nik,
    required this.phone,
    required this.posyanduName,
    required this.workArea,
    required this.role,
  });
}
