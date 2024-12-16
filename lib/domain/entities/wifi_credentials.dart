abstract class WifiCredentials {}

class PersonalCredentials extends WifiCredentials {
  final String password;
  PersonalCredentials(this.password);
}

class EnterpriseCredentials extends WifiCredentials {
  final String username;
  final String password;
  final String? caCertificatePath; // if needed

  EnterpriseCredentials({
    required this.username,
    required this.password,
    this.caCertificatePath,
  });
}