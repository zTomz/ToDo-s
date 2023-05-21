import 'package:encrypt/encrypt.dart';

class ToDo {
  final String title;
  final String content;
  final bool completed;
  final DateTime from;

  ToDo({
    required this.title,
    required this.content,
    required this.completed,
    required this.from,
  });

  Map<String, dynamic> toEncryptJson(Encrypter encrypter, IV iv) {
    return {
      "title": encrypter.encrypt(title, iv: iv).base64,
      "content": encrypter.encrypt(content, iv: iv).base64,
      "completed": completed,
      "from": encrypter
          .encrypt(from.millisecondsSinceEpoch.toString(), iv: iv)
          .base64,
    };
  }

  ToDo.fromJson(Map<String, dynamic> json, Encrypter encrypter, IV iv)
      : title = encrypter.decrypt(Encrypted.fromBase64(json["title"]), iv: iv),
        content =
            encrypter.decrypt(Encrypted.fromBase64(json["content"]), iv: iv),
        completed = json["completed"],
        from = DateTime.fromMillisecondsSinceEpoch(
          int.parse(
            encrypter.decrypt(Encrypted.fromBase64(json["from"]), iv: iv),
          ),
        );
}
