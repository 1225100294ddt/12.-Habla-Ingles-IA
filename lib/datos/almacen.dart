import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dominio/repaso.dart';
class Almacen {
  static const _key='habla_fluido_v1';
  Future<Map<String,dynamic>> cargar() async {
    final p=await SharedPreferences.getInstance(); final raw=p.getString(_key);
    if(raw==null)return {};
    try{return jsonDecode(raw) as Map<String,dynamic>;}catch(_){return {};}
  }
  Future<void> guardar(Map<String,dynamic> datos) async {
    final p=await SharedPreferences.getInstance(); await p.setString(_key,jsonEncode(datos));
  }
  Future<List<TarjetaRepaso>> tarjetas() async {
    final d=await cargar(); final raw=d['tarjetas'];
    if(raw is! List)return [];
    return raw.whereType<Map>().map((e){try{return TarjetaRepaso.fromJson(Map<String,dynamic>.from(e));}catch(_){return null;}})
      .whereType<TarjetaRepaso>().toList();
  }
}
