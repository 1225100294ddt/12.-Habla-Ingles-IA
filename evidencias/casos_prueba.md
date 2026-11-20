# Casos de prueba documentados (escenarios de ejemplo)

| ID | Módulo | Entrada | Resultado esperado |
|---|---|---|---|
| CP-01 | Comparador | `Where is the bathroom?` / `where is the bathroom` | 100% de coincidencia |
| CP-02 | Comparador | `I think the ship is big` / `i tink the sheep is big` | `tink` parecida y `sheep` sustituida |
| CP-03 | SM-2 | Calificaciones 4, 5, 5 y 2 | Intervalos 1, 6, 16 y 1 día |
| CP-04 | Plan diario | Sesión de 20 minutos | Los cinco bloques suman exactamente 20 minutos |
| CP-05 | Proxy | Mensaje de 501 caracteres | Solicitud rechazada por validación |
| CP-06 | Proxy | Roles consecutivos iguales | Solicitud rechazada por alternancia |

Estos escenarios describen las pruebas implementadas; solo las seis pruebas Node cuentan con salida real guardada en `pruebas_proxy.txt`. Las imágenes son maquetas ilustrativas.
