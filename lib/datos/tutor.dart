import 'dart:convert';
import 'package:http/http.dart' as http;
class Tutor {
  final String baseUrl; final String? token;
  Tutor({required this.baseUrl,this.token});
  Future<Map<String,dynamic>> conversar(List<Map<String,String>> historial,String nivel) async {
    if(historial.isEmpty || historial.length>20) throw Exception('Historial inválido');
    for(final m in historial){if(!['user','assistant'].contains(m['role']) || (m['content']??'').trim().isEmpty || m['content']!.length>500) throw Exception('Mensaje inválido');}
    final uri=Uri.parse('$baseUrl/chat');
    if(uri.scheme!='https' && uri.host!='localhost' && uri.host!='10.0.2.2') throw Exception('El servidor debe usar HTTPS');
    try{
      final r=await http.post(uri,headers:{'Content-Type':'application/json',if(token!=null)'x-app-token':token!},
        body:jsonEncode({'nivel':nivel,'mensajes':historial})).timeout(const Duration(seconds:20));
      if(r.statusCode!=200)throw Exception('Tutor no disponible');
      final data=jsonDecode(r.body);
      if(data is! Map || data['respuesta'] is! String || (data['respuesta'] as String).length>1000)throw Exception('Respuesta inválida');
      return Map<String,dynamic>.from(data);
    }catch(_){throw Exception('El tutor no está disponible ahora. Intenta en un momento.');}
  }
}
