class UserData {
  final int? id;
  final String name;
  final String email;
  final String outputImageFilename;

  UserData({
    this.id,
    required this.name,
    required this.email,
    required this.outputImageFilename,
  });

  UserData copyWith({
    int? id,
    String? name,
    String? email,
    String? outputImageFilename,
  }) =>
      UserData(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        outputImageFilename: outputImageFilename ?? this.outputImageFilename,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'output_image_filename': outputImageFilename,
    };
  }

  static UserData fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      outputImageFilename: map['output_image_filename'] as String,
    );
  }
}