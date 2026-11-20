import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
class Voz {
  final FlutterTts _tts=FlutterTts();
  final SpeechToText _stt=SpeechToText();
  Future<void> hablar(String texto,{double velocidad=0.5}) async {
    await _tts.setLanguage('en-US'); await _tts.setSpeechRate(velocidad); await _tts.speak(texto);
  }
  Future<String?> escuchar() async {
    final ok=await _stt.initialize(); if(!ok)return null;
    String? resultado;
    await _stt.listen(localeId:'en_US',onResult:(r){if(r.finalResult)resultado=r.recognizedWords;});
    await Future.delayed(const Duration(seconds:8)); await _stt.stop();
    return resultado;
  }
  Future<void> detener() async {await _tts.stop();await _stt.stop();}
}
