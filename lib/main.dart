import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'dominio/comparador.dart';
import 'dominio/nivel.dart';
import 'dominio/plan_diario.dart';
import 'dominio/progreso.dart';
import 'dominio/repaso.dart';
import 'datos/almacen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HablaFluidoApp());
}

class HablaFluidoApp extends StatelessWidget {
  const HablaFluidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habla Fluido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff3157a4),
        ),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int tab = 0;

  final Almacen almacen = Almacen();
  final Progreso progreso = Progreso();

  List<TarjetaRepaso> tarjetas = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final datos = await almacen.cargar();

      final p = datos['progreso'];

      if (p is Map) {
        progreso.nivel = NivelCefr.values.firstWhere(
          (e) => e.name == p['nivel'],
          orElse: () => NivelCefr.a1,
        );

        progreso.racha =
            (p['racha'] as num?)?.toInt() ?? 0;
      }

      tarjetas = await almacen.tarjetas();

      if (tarjetas.isEmpty) {
        tarjetas = [
          TarjetaRepaso(
            id: '1',
            frase: 'Could you help me, please?',
            traduccion: '¿Podría ayudarme, por favor?',
            proxima: DateTime.now(),
          ),
          TarjetaRepaso(
            id: '2',
            frase: 'Where is the bus station?',
            traduccion: '¿Dónde está la estación de autobuses?',
            proxima: DateTime.now(),
          ),
          TarjetaRepaso(
            id: '3',
            frase: 'I would like some water.',
            traduccion: 'Me gustaría un poco de agua.',
            proxima: DateTime.now(),
          ),
        ];
      }
    } catch (e) {
      tarjetas = [];
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> guardarDatos() async {
    await almacen.guardar({
      'progreso': {
        'nivel': progreso.nivel.name,
        'racha': progreso.racha,
      },
      'tarjetas': tarjetas.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> registrar(
    Habilidad habilidad,
    double puntaje,
  ) async {
    progreso.registrar(
      habilidad,
      puntaje,
      DateTime.now(),
    );

    await guardarDatos();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final paginas = [
      inicio(),
      ejercicios(),
      repaso(),
      perfil(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habla Fluido'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: paginas[tab],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (valor) {
          setState(() {
            tab = valor;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Practicar',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            label: 'Repaso',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }

  Widget inicio() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola! Vamos a practicar',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Nivel ${progreso.nivel.etiqueta} · '
                'Racha: ${progreso.racha} días',
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    tab = 1;
                  });
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Comenzar sesión'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Tu plan de hoy',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...generarPlan(progreso).map(
          (bloque) => Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(icono(bloque.habilidad)),
              ),
              title: Text(bloque.habilidad.nombre),
              subtitle: Text(
                bloque.esRefuerzo
                    ? 'Refuerzo recomendado'
                    : 'Práctica diaria',
              ),
              trailing: Text('${bloque.minutos} min'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Practica un poco cada día. '
          'La constancia ayuda más que estudiar todo de golpe.',
        ),
      ],
    );
  }

  IconData icono(Habilidad habilidad) {
    switch (habilidad) {
      case Habilidad.escucha:
        return Icons.hearing;
      case Habilidad.pronunciacion:
        return Icons.record_voice_over;
      case Habilidad.lectura:
        return Icons.menu_book;
      case Habilidad.escritura:
        return Icons.edit;
      case Habilidad.conversacion:
        return Icons.chat;
    }
  }

  Widget ejercicios() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Elige una actividad',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        tarjeta(
          'Pronunciación',
          'Escucha una frase y repítela.',
          () => abrir(const PronunciacionPage()),
        ),
        tarjeta(
          'Dictado',
          'Compara lo que escuchaste con la frase correcta.',
          () => abrir(const DictadoPage()),
        ),
        tarjeta(
          'Lectura',
          'Lee un texto breve y responde preguntas.',
          () => abrir(const LecturaPage()),
        ),
        tarjeta(
          'Escritura',
          'Escribe en inglés y revisa sugerencias.',
          () => abrir(const EscrituraPage()),
        ),
        tarjeta(
          'Conversación',
          'Practica respuestas con un tutor de demostración.',
          () => abrir(const ConversacionPage()),
        ),
      ],
    );
  }

  Widget tarjeta(
    String titulo,
    String descripcion,
    VoidCallback accion,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome, size: 28),
        title: Text(titulo),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.chevron_right),
        onTap: accion,
      ),
    );
  }

  void abrir(Widget pagina) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pagina,
      ),
    );
  }

  Widget repaso() {
    final pendientes = tarjetas
        .where((t) => t.estaVencida(DateTime.now()))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Repetición espaciada',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Intenta recordar la frase antes de mostrar su traducción.',
        ),
        const SizedBox(height: 15),

        if (pendientes.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                '¡Todo al día! Vuelve cuando tengas nuevas frases.',
              ),
            ),
          ),

        ...pendientes.map((tarjeta) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(tarjeta.frase),
              subtitle: const Text(
                'Toca para revelar la traducción',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    tarjeta.traduccion,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: [
                    TextButton(
                      onPressed: () {
                        calificarTarjeta(tarjeta, 2);
                      },
                      child: const Text('Difícil'),
                    ),
                    TextButton(
                      onPressed: () {
                        calificarTarjeta(tarjeta, 3);
                      },
                      child: const Text('Bien'),
                    ),
                    TextButton(
                      onPressed: () {
                        calificarTarjeta(tarjeta, 5);
                      },
                      child: const Text('Fácil'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> calificarTarjeta(
    TarjetaRepaso tarjeta,
    int calidad,
  ) async {
    final indice = tarjetas.indexWhere(
      (t) => t.id == tarjeta.id,
    );

    if (indice == -1) return;

    setState(() {
      tarjetas[indice] = tarjeta.calificar(
        calidad,
        DateTime.now(),
      );
    });

    await guardarDatos();
  }

  Widget perfil() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Mi progreso',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Card(
          child: ListTile(
            title: const Text('Nivel actual'),
            trailing: Chip(
              label: Text(progreso.nivel.etiqueta),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Racha de práctica'),
            trailing: Text('${progreso.racha} días'),
          ),
        ),
        ...Habilidad.values.map(
          (habilidad) {
            final dominio =
                progreso.dominioDe(habilidad).clamp(0.0, 1.0);

            return ListTile(
              title: Text(habilidad.nombre),
              subtitle: LinearProgressIndicator(
                value: dominio,
              ),
              trailing: Text(
                '${(dominio * 100).round()}%',
              ),
            );
          },
        ),
        const Text(
          'El nivel se actualiza cuando todas las habilidades '
          'cumplen el dominio y los intentos mínimos.',
        ),
      ],
    );
  }
}

// PRONUNCIACIÓN

class PronunciacionPage extends StatefulWidget {
  const PronunciacionPage({super.key});

  @override
  State<PronunciacionPage> createState() =>
      _PronunciacionPageState();
}

class _PronunciacionPageState
    extends State<PronunciacionPage> {
  final String frase = 'I would like a glass of water.';

  final FlutterTts tts = FlutterTts();
  final SpeechToText stt = SpeechToText();

  String dicho = '';
  String estado = 'Pulsa escuchar y después repite.';

  Future<void> hablar([double velocidad = 0.5]) async {
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(velocidad);
    await tts.speak(frase);
  }

  Future<void> escuchar() async {
    final disponible = await stt.initialize();

    if (!disponible) {
      setState(() {
        estado = 'No se pudo activar el micrófono.';
      });
      return;
    }

    setState(() {
      dicho = '';
      estado = 'Escuchando...';
    });

    await stt.listen(
      localeId: 'en_US',
      onResult: (resultado) {
        if (mounted) {
          setState(() {
            dicho = resultado.recognizedWords;
          });
        }
      },
    );
  }

  Future<void> detenerEscucha() async {
    await stt.stop();

    if (mounted) {
      setState(() {
        estado = dicho.isEmpty
            ? 'No se detectó voz.'
            : 'Resultado listo.';
      });
    }
  }

  @override
  void dispose() {
    tts.stop();
    stt.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciación')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Repite la frase en voz alta.'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  frase,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => hablar(),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Escuchar'),
                ),
                OutlinedButton(
                  onPressed: () => hablar(0.3),
                  child: const Text('Lento'),
                ),
                OutlinedButton(
                  onPressed: escuchar,
                  child: const Text('Repetir'),
                ),
                OutlinedButton(
                  onPressed: detenerEscucha,
                  child: const Text('Terminar'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(estado),
            Text('Reconocido: $dicho'),
          ],
        ),
      ),
    );
  }
}

// DICTADO

class DictadoPage extends StatefulWidget {
  const DictadoPage({super.key});

  @override
  State<DictadoPage> createState() => _DictadoPageState();
}

class _DictadoPageState extends State<DictadoPage> {
  final String esperado = 'Where is the nearest pharmacy';

  final TextEditingController ctrl = TextEditingController();

  ResultadoComparacion? resultado;

  Future<void> escucharFrase() async {
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    await tts.speak(esperado);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictado')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Escucha la frase modelo y escríbela.'),
          FilledButton.icon(
            onPressed: escucharFrase,
            icon: const Icon(Icons.volume_up),
            label: const Text('Escuchar frase'),
          ),
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Escribe lo que escuchaste',
              border: OutlineInputBorder(),
            ),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                resultado = comparar(esperado, ctrl.text);
              });
            },
            child: const Text('Comprobar'),
          ),
          if (resultado != null) ...[
            Text(
              'Resultado: ${(resultado!.puntaje * 100).round()}% '
              '· ${resultado!.aprobado ? 'Aprobado' : 'Sigue practicando'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              children: resultado!.palabras.map((palabra) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Chip(
                    label: Text(
                      palabra.dicha ?? palabra.esperada ?? '',
                    ),
                  ),
                );
              }).toList(),
            ),
            Text(
              'Para practicar: ${resultado!.porPracticar.join(', ')}',
            ),
          ],
        ],
      ),
    );
  }
}

// LECTURA

class LecturaPage extends StatefulWidget {
  const LecturaPage({super.key});

  @override
  State<LecturaPage> createState() => _LecturaPageState();
}

class _LecturaPageState extends State<LecturaPage> {
  int? seleccion;
  bool enviado = false;

  @override
  Widget build(BuildContext context) {
    final opciones = [
      'To the beach',
      'To the town center',
      'To the airport',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Lectura')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'A day in Dolores Hidalgo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text(
            'Maria visits the town center every Saturday. '
            'She likes the colorful market and the historic church. '
            'After lunch, she walks through the garden and talks with visitors.',
          ),
          const SizedBox(height: 20),
          const Text('Where does Maria go on Saturday?'),
          ...opciones.asMap().entries.map(
            (opcion) => RadioListTile<int>(
              value: opcion.key,
              groupValue: seleccion,
              onChanged: enviado
                  ? null
                  : (valor) {
                      setState(() {
                        seleccion = valor;
                      });
                    },
              title: Text(opcion.value),
            ),
          ),
          FilledButton(
            onPressed: seleccion == null || enviado
                ? null
                : () {
                    setState(() {
                      enviado = true;
                    });
                  },
            child: const Text('Responder'),
          ),
          if (enviado)
            Text(
              seleccion == 1
                  ? 'Correct! Well done.'
                  : 'Not quite. Read the first sentence again.',
            ),
        ],
      ),
    );
  }
}

// ESCRITURA

class EscrituraPage extends StatefulWidget {
  const EscrituraPage({super.key});

  @override
  State<EscrituraPage> createState() => _EscrituraPageState();
}

class _EscrituraPageState extends State<EscrituraPage> {
  final TextEditingController ctrl = TextEditingController();

  String resultado = '';

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escritura')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Write five or more words about your favorite place.',
          ),
          TextField(
            controller: ctrl,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'My favorite place is...',
            ),
          ),
          FilledButton(
            onPressed: () {
              final palabras = ctrl.text
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((x) => x.isNotEmpty)
                  .length;

              setState(() {
                resultado = palabras < 5
                    ? 'Escribe al menos 5 palabras.'
                    : 'Buen trabajo. Revisa mayúsculas, '
                        'puntuación y verbos. ($palabras palabras)';
              });
            },
            child: const Text('Revisar texto'),
          ),
          Text(resultado),
        ],
      ),
    );
  }
}

// CONVERSACIÓN

class ConversacionPage extends StatefulWidget {
  const ConversacionPage({super.key});

  @override
  State<ConversacionPage> createState() =>
      _ConversacionPageState();
}

class _ConversacionPageState extends State<ConversacionPage> {
  final TextEditingController ctrl = TextEditingController();

  final List<String> mensajes = [
    'Tutor: Hi! What do you like doing in your free time?',
  ];

  void enviar() {
    final texto = ctrl.text.trim();

    if (texto.isEmpty || texto.length > 500) {
      return;
    }

    setState(() {
      mensajes.add('Tú: $texto');

      mensajes.add(
        'Tutor: Nice! Recuerda usar frases completas. '
        'What do you usually do on weekends?',
      );

      ctrl.clear();
    });
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversación')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: mensajes.map((mensaje) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(mensaje),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Escribe en inglés',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: enviar,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}