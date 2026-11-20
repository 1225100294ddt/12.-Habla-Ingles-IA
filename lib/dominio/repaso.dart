class TarjetaRepaso {
  final String id, frase, traduccion;
  final double facilidad;
  final int intervaloDias, repeticiones;
  final DateTime proxima;
  const TarjetaRepaso({required this.id,required this.frase,required this.traduccion,required this.proxima,
    this.facilidad=2.5,this.intervaloDias=0,this.repeticiones=0});
  bool estaVencida(DateTime hoy) => !_fecha(proxima).isAfter(_fecha(hoy));
  TarjetaRepaso calificar(int calidad, DateTime hoy) {
    if (calidad<0 || calidad>5) throw ArgumentError('La calidad va de 0 a 5');
    var reps=repeticiones, intervalo=intervaloDias;
    if(calidad<3){reps=0;intervalo=1;} else {reps++; intervalo=reps==1?1:(reps==2?6:(intervaloDias*facilidad).round());}
    final q=5-calidad;
    final ef=(facilidad+(0.1-q*(0.08+q*0.02))).clamp(1.3,10.0).toDouble();
    final d=_fecha(hoy);
    return TarjetaRepaso(id:id,frase:frase,traduccion:traduccion,facilidad:ef,intervaloDias:intervalo,
      repeticiones:reps,proxima:DateTime(d.year,d.month,d.day+intervalo));
  }
  Map<String,Object?> toJson()=>{'id':id,'frase':frase,'traduccion':traduccion,'facilidad':facilidad,
    'intervaloDias':intervaloDias,'repeticiones':repeticiones,'proxima':proxima.toIso8601String()};
  factory TarjetaRepaso.fromJson(Map<String,dynamic> j)=>TarjetaRepaso(id:j['id'],frase:j['frase'],traduccion:j['traduccion'],
    facilidad:(j['facilidad'] as num).toDouble(),intervaloDias:j['intervaloDias'],repeticiones:j['repeticiones'],proxima:DateTime.parse(j['proxima']));
}
DateTime _fecha(DateTime d)=>DateTime(d.year,d.month,d.day);
int calidadDesdePuntaje(double p)=>p>=.95?5:p>=.85?4:p>=.70?3:p>=.50?2:p>=.30?1:0;
