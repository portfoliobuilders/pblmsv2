class User {
  String name;
  String enrolmentnumb;
  String branch;
  String course;
  String JoiningDate;
  String email;
  String password;
  User(
      {required this.name,
      required this.enrolmentnumb,
      required this.branch,
      required this.course,
      required this.JoiningDate,
      required this.email,
      required this.password});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'enrolmentnumb': enrolmentnumb,
      'branch': branch,
      'course': course,
      "JoiningDate":JoiningDate,
       "email":email,
        "password":password
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      enrolmentnumb: json['enrolmentnumb'] ?? '',
      branch: json['branch'] ?? '',
      course: json['course'] ?? '',
      JoiningDate:json["JoiningDate"]??'',
      email:json["email"]??'',
      password:json["password"]??'',
    );
  }
}
