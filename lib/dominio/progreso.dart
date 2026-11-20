import 'nivel.dart';
import 'reglas.dart';
class DominioHabilidad { final double dominio; final int intentos; const DominioHabilidad(this.dominio,this.intentos); }
class Progreso {
  final Map<Habilidad,DominioHabilidad> habilidades;
  NivelCefr nivel; int racha; DateTime? ultimoDia;
  Progreso({Map<Habilidad,DominioHabilidad>? habilidades,this.nivel=NivelCefr.a1,this.racha=0,this.ultimoDia})
    : habilidades={...?habilidades};
  double dominioDe(Habilidad h)=>habilidades[h]?.dominio??Reglas.dominioSinEvaluar;
  Habilidad get masDebil=>Habilidad.values.reduce((a,b)=>dominioDe(a)<=dominioDe(b)?a:b);
  void registrar(Habilidad h,double puntaje,DateTime hoy) {
    final p=puntaje.clamp(0.0,1.0).toDouble(), actual=habilidades[h];
    habilidades[h]=DominioHabilidad(actual==null?p:actual.dominio*(1-Reglas.pesoUltimoIntento)+p*Reglas.pesoUltimoIntento,(actual?.intentos??0)+1);
    final dia=DateTime(hoy.year,hoy.month,hoy.day), anterior=ultimoDia==null?null:DateTime(ultimoDia!.year,ultimoDia!.month,ultimoDia!.day);
    if(anterior==null || dia.difference(anterior).inDays>1) racha=1;
    else if(dia.difference(anterior).inDays==1) racha++;
    ultimoDia=dia;
  }
  bool get puedeSubirDeNivel=>nivel.siguiente!=null && Habilidad.values.every((h)=>(habilidades[h]?.intentos??0)>=Reglas.intentosParaSubir && dominioDe(h)>=Reglas.dominioParaSubir);
  bool subirNivel(){if(!puedeSubirDeNivel)return false;nivel=nivel.siguiente!;habilidades.clear();return true;}
}
