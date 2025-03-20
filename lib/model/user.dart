class User {
  final String username;
  final String password;

  const User({
    required this.username,
    required this.password,
  });
}

const users = [
  User(username: 'kasir', password: 'kasir123'),
  User(username: 'admin', password: 'admin123'),
];
