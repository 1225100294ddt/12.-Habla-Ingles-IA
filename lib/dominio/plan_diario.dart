import 'nivel.dart';
import 'progreso.dart';
import 'reglas.dart';
class BloquePlan { final Habilidad habilidad; final int minutos; final bool esRefuerzo; const BloquePlan(this.habilidad,this.minutos,{this.esRefuerzo=false}); }
const pesosBase={Habilidad.escucha:.20,Habilidad.pronunciacion:.20,Habilidad.lectura:.20,Habilidad.escritura:.15,Habilidad.conversacion:.25};
List<BloquePlan> generarPlan(Progreso progreso,{int minutosTotales=Reglas.minutosPorSesion}) {
  if(minutosTotales<Habilidad.values.length) throw ArgumentError('Se requiere al menos un minuto por habilidad');
  final debil=progreso.masDebil, hs=Habilidad.values;
  final pesos=[for(final h in hs) pesosBase[h]!+(h==debil?Reglas.extraHabilidadDebil:0)];
  final suma=pesos.fold<double>(0,(a,b)=>a+b), crudos=[for(final w in pesos) w/suma*minutosTotales];
  final mins=[for(final c in crudos)c.floor()];
  var resto=minutosTotales-mins.fold<int>(0,(a,b)=>a+b);
  final orden=List<int>.generate(hs.length,(i)=>i)..sort((a,b){
    final c=(crudos[b]-mins[b]).compareTo(crudos[a]-mins[a]);return c!=0?c:a.compareTo(b);
  });
  for(var k=0;k<resto;k++) mins[orden[k]]++;
  return [for(var i=0;i<hs.length;i++) BloquePlan(hs[i],mins[i],esRefuerzo:hs[i]==debil)];
}
