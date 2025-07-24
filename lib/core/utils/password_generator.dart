import 'dart:math';

class PasswordGenerator {
  static const String _letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*';
  
  static String generateSecurePassword({
    int length = 12,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    final random = Random.secure();
    String chars = _letters;
    
    if (includeNumbers) chars += _numbers;
    if (includeSymbols) chars += _symbols;
    
    String password = '';
    
    // Ensure at least one character from each category
    password += _letters[random.nextInt(_letters.length)];
    if (includeNumbers) {
      password += _numbers[random.nextInt(_numbers.length)];
    }
    if (includeSymbols) {
      password += _symbols[random.nextInt(_symbols.length)];
    }
    
    // Fill remaining length with random characters
    int remainingLength = length - password.length;
    for (int i = 0; i < remainingLength; i++) {
      password += chars[random.nextInt(chars.length)];
    }
    
    // Shuffle the password to randomize positions
    List<String> passwordList = password.split('');
    passwordList.shuffle(random);
    
    return passwordList.join('');
  }
  
  static String generateReadablePassword({int length = 12}) {
    // Generate a more readable password using common words and numbers
    final random = Random.secure();
    final words = [
      'robot', 'speed', 'power', 'smart', 'quick', 'brave', 'strong', 'fast',
      'tech', 'code', 'game', 'win', 'jump', 'run', 'move', 'play',
    ];
    
    String password = '';
    
    // Add 2-3 words
    int wordCount = 2 + random.nextInt(2);
    for (int i = 0; i < wordCount; i++) {
      if (i > 0) password += '-';
      String word = words[random.nextInt(words.length)];
      // Capitalize randomly
      if (random.nextBool()) {
        word = word[0].toUpperCase() + word.substring(1);
      }
      password += word;
    }
    
    // Add numbers at the end
    int numbers = 100 + random.nextInt(900);
    password += numbers.toString();
    
    return password;
  }
}