import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/dominio/comparador.dart';
void main(){
 test('normaliza mayúsculas y puntuación',(){expect(normalizar("Don't worry, be HAPPY!"),["don't",'worry','be','happy']);});
 test('Levenshtein',(){expect(distanciaLevenshtein('ship','sheep'),2);expect(distanciaLevenshtein('kitten','sitting'),3);});
 test('frase idéntica obtiene 100%',(){final r=comparar('Where is the bathroom?','where is the bathroom');expect(r.puntaje,1);expect(r.aprobado,isTrue);});
 test('marca palabra parecida y sustituida',(){final r=comparar('I think the ship is big','i tink the sheep is big');expect(r.palabras[1].estado,EstadoPalabra.parecida);expect(r.palabras[3].estado,EstadoPalabra.sustituida);});
 test('palabra omitida',(){final r=comparar('I want to go home','i want go home');expect(r.puntaje,closeTo(.8,1e-9));});
}
