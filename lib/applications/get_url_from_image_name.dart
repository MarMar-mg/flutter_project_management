import 'package:managment_flutter_project/applications/constants.dart';

String getUrlFromImageName(String imageName) {
  if (imageName.isEmpty) return '';
  return '${BASE_URL}files/avatar/$imageName';
}

String getUrlFromAudioName(String imageName) {
  if (imageName.isEmpty) return '';
  return '${BASE_URL}files/audio/$imageName';
}

String getUrlFromVideoName(String imageName) {
  if (imageName.isEmpty) return '';
  return '${BASE_URL}files/video/$imageName';
}
