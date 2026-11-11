# Documento de diseño y desarrollo
## Demo 3D — Escape Room: La casa cerrada

**Motor:** Godot 4  
**Género:** Escape Room / Exploración / Puzles  
**Perspectiva:** Primera persona  
**Modalidad:** Un jugador  
**Duración estimada:** 10–15 minutos  
**Objetivo:** Crear una experiencia jugable corta en la que el jugador debe explorar una casa, resolver tres puzles, conseguir las llaves necesarias y escapar al exterior.

---

# 1. Concepto general

El jugador comienza encerrado en una habitación de una casa. La puerta principal está cerrada y necesita encontrar una serie de llaves repartidas por los diferentes ambientes para poder escapar.

La experiencia se centra en la exploración, observación, recolección de objetos y resolución de puzles.

La demo debe contar con un principio, un desarrollo y un final claramente identificables.

## 1.1. Objetivos de diseño

- Crear una experiencia sencilla pero completa.
- Introducir progresivamente las mecánicas de exploración e interacción.
- Ofrecer tres puzles diferentes.
- Mantener una progresión lineal y fácil de comprender.
- Construir una casa pequeña, visualmente coherente y explorable.
- Alcanzar un nivel de presentación suficiente para mostrar el funcionamiento del juego.

## 1.2. Características fuera del alcance

Para mantener reducido el tiempo de desarrollo, no se implementarán:

- Combate.
- Enemigos o inteligencia artificial.
- Multijugador.
- Sistema de supervivencia.
- Inventario complejo.
- Guardado de partidas.
- Sistema de misiones avanzado.
- Generación procedural.
- Múltiples finales.

---

# 2. Diseño del escenario

La demo transcurre en una casa pequeña, compuesta por cinco ambientes interiores y un exterior.

## 2.1. Distribución

| Ambiente | Función |
|---|---|
| Dormitorio | Habitación inicial y primer puzle. |
| Pasillo | Conexión entre los ambientes. |
| Sala de estar | Segundo puzle. |
| Cocina | Tercer puzle. |
| Entrada | Puerta principal y salida. |
| Exterior | Escena final. |

Dimensiones orientativas de la construcción: 10 × 12 metros.

La distribución debe permitir que el jugador comprenda fácilmente cómo se conectan las habitaciones.

## 2.2. Dirección artística

Se utilizará un estilo 3D sencillo y estilizado.

Prioridades:
- Geometría simple.
- Modelos de muebles reutilizables.
- Materiales fáciles de distinguir.
- Iluminación que permita identificar los objetos importantes.
- Decoración moderada, evitando objetos innecesarios.

Se pueden utilizar modelos propios de Blender y recursos externos con licencias compatibles con el proyecto.

---

# 3. Progresión y puzles

La progresión estará dividida en tres etapas. Cada puzle proporciona una llave necesaria para acceder al siguiente ambiente.

## 3.1. Primer puzle: Caja fuerte cerrada

**Ubicación:** Dormitorio inicial.

El jugador encuentra un ropero con caja fuerte de 5 símbolos

Elementos importantes:
- Puerta cerrada con llave.
- Ropero con caja fuerte.
- Tres cuadros con símbolos.
- Escritorio con cajon y nota en su interior.

Problema:
- El jugador debe acceder a la llave dentro de la caja fuerte.
- La caja fuerte se desbloquea presionando 3 de 5 botones en orden correcto.

Resolución:
1. Los tres cuadros muestran un paisaje y un símbolo.
2. La nota indica en que orden se presionan los botones mencionando los paisajes.

**Recompensa:** Llave que permite salir del dormitorio y acceder al pasillo.

## 3.2. Segundo puzle: Puerta con código

**Ubicación:** Sala de estar.

En el pasillo el jugador encuentra la puerta de la cocina cerrada con una cerradura de código y una nota que indica que la contraseña se encuentra en la sala de estar.
(este pasillo también conecta la sala de estar, el baño y la entrada principal)

Elementos:
- Puerta con cerradura de código (4 dígitos).
- Puerta accesible a la sala de estar.
- Sofá con almohadones extraibles.

Resolución:
1. El jugador levanta los almohadones y encuentra una nota con la contraseña.

**Recompensa:** Código que permite acceder a la cocina.

## 3.3. Tercer puzle: Lata de alimento

**Ubicación:** Cocina.

El jugador encuentra una lata de alimento sospechosa.

Elementos:
- Heladera con lata de alimento dentro.
- Cocina con gas.
- Llave del baño.

Resolución:
1. El jugador va al baño para encontrar fósforos.
2. Usa los fósforos para encender la cocina.
3. Coloca la lata en el fuego para que explote con el calor.

**Recompensa:** Llave de la puerta principal.

## 3.4. Finalización

El jugador regresa a la entrada, utiliza la llave para abrir la puerta principal y sale al exterior.

Al atravesar la salida:
- Se activa una transición o pantalla de finalización.
- Se muestra un mensaje de demo completada.
- Se ofrece la posibilidad de volver a jugar o cerrar la experiencia.

---

# 4. Mecánicas principales

## 4.1. Controlador en primera persona

El jugador podrá:
- Caminar.
- Mirar alrededor con el ratón.
- Interactuar con objetos.
- Recoger elementos.
- Utilizar objetos del inventario.

Controles propuestos:

| Acción | Control |
|---|---|
| Movimiento | WASD |
| Mirar | Ratón |
| Interactuar | E |
| Soltar o cerrar interfaz | Escape |
| Liberar/capturar ratón | Escape |

## 4.2. Sistema de interacción

Se utilizará un RayCast3D desde la cámara para detectar los objetos que el jugador está mirando.

Cuando un objeto interactuable esté dentro del alcance:
- Se mostrará un indicador de interacción.
- Se mostrará el nombre o una descripción breve.
- Al presionar E se ejecutará su acción correspondiente.

Ejemplos:
- Puertas: abrir, cerrar o desbloquear.
- Cajones: abrir o examinar.
- Llaves: recoger.
- Notas: leer.
- Cerraduras: introducir combinaciones.

## 4.3. Inventario

El inventario será deliberadamente sencillo.

Solo almacenará los objetos relevantes para la progresión:
- Llave del dormitorio.
- Lata y fósforos.
- Llave de salida.

No se implementarán peso, dimensiones, equipamiento ni administración avanzada.

## 4.4. Sistema de cerraduras

Las cerraduras comprobarán si el inventario contiene el objeto necesario.

Si el jugador tiene la llave correspondiente:
- Se desbloquea la puerta.
- Se reproduce una animación.
- Se actualiza el estado de la puerta.

Si no la tiene, se muestra un mensaje explicativo.

## 4.5. Sistema de puzles

Cada puzle tendrá:
- Un estado de resolución.
- Elementos interactuables.
- Una interfaz cuando sea necesaria.
- Una condición de éxito.
- Una recompensa o consecuencia.

Los puzles deben poder resolverse una sola vez y conservar su estado durante la partida.

---

# 5. Arquitectura inicial de Godot

Se utilizarán escenas reutilizables para separar el jugador, los objetos interactuables, las puertas y los puzles.

## 5.1. Escena principal

```text
Main
├── World
│   ├── House
│   │   ├── Bedroom
│   │   ├── Hallway
│   │   ├── LivingRoom
│   │   ├── Kitchen
│   │   └── Entrance
│   └── Exterior
├── Player
├── GameManager
└── UI
	├── Crosshair
	├── InteractionLabel
	├── InventoryUI
	└── PuzzleUI
```

## 5.2. Escenas reutilizables

```text
Player/
	Player.tscn

Interactables/
	InteractableObject.tscn
	Door.tscn
	Note.tscn
	Drawer.tscn
	Cushion.tscn
	Stove.tscn
	
Colectibles/
	Key.tscn
	Can.tscn
	Match.tscn

Puzzles/
	SymbolLock.tscn
	NumberLock.tscn
	CanExplosion.tscn

Environment/
	Furniture/
	Props/
	Materials/
```

La estructura podrá modificarse durante el desarrollo. No es necesario construir todos estos archivos desde el primer día.

## 5.3. Organización de carpetas

```text
res://
├── assets/
│   ├── models/
│   ├── materials/
│   ├── textures/
│   ├── audio/
│   └── fonts/
├── scenes/
│   ├── main/
│   ├── player/
│   ├── environment/
│   ├── interactables/
│   ├── colectibles/
│   ├── puzzles/
│   └── ui/
├── scripts/
│   ├── player/
│   ├── interactables/
│   ├── colectibles/
│   ├── puzzles/
│   └── managers/
└── resources/
```

---

# 6. Plan de desarrollo paso a paso

El desarrollo se dividirá en etapas. Cada etapa debe finalizar con una prueba funcional antes de continuar.

## Etapa 1 — Proyecto y controlador del jugador

Objetivo: disponer de un personaje que pueda recorrer un escenario 3D.

Tareas:
1. Crear el proyecto Godot 4.
2. Configurar la resolución y los ajustes iniciales.
3. Crear la escena Player.
4. Implementar CharacterBody3D.
5. Incorporar Camera3D.
6. Configurar los controles de movimiento.
7. Implementar rotación de cámara con el ratón.
8. Configurar colisiones.
9. Crear un escenario de prueba con suelo y paredes.

**Criterio de finalización:** el jugador puede caminar y mirar alrededor sin atravesar la geometría.

## Etapa 2 — Interacción con objetos

Objetivo: permitir que el jugador interactúe con los elementos del escenario.

Tareas:
1. Añadir RayCast3D a la cámara.
2. Detectar objetos interactuables.
3. Crear una interfaz para mostrar indicaciones.
4. Implementar la acción de interacción.
5. Crear una escena base para objetos interactuables.
6. Probar la interacción con puertas, cajones y notas.

**Criterio de finalización:** el jugador puede mirar un objeto, reconocer que es interactuable y ejecutar su acción.

## Etapa 3 — Inventario y puertas

Objetivo: implementar la progresión mediante llaves.

Tareas:
1. Crear un inventario sencillo.
2. Implementar la recolección de objetos.
3. Registrar las llaves obtenidas.
4. Crear una puerta interactuable.
5. Implementar cerraduras que requieren una llave.
6. Añadir mensajes para indicar si una puerta está bloqueada.
7. Probar la progresión entre dos habitaciones.

**Criterio de finalización:** el jugador puede recoger una llave y utilizarla para desbloquear una puerta.

## Etapa 4 — Primer puzle

Objetivo: implementar el puzle de símbolos del dormitorio.

Tareas:
1. Crear los objetos que representan los símbolos.
2. Crear una nota con las instrucciones.
3. Diseñar la interfaz de combinación.
4. Comprobar la secuencia introducida.
5. Abrir el cajón cuando la combinación sea correcta.
6. Entregar la primera llave.

**Criterio de finalización:** el puzle se puede resolver de principio a fin y proporciona la primera llave.

## Etapa 5 — Segundo puzle

Objetivo: implementar la cerradura numerica.

Tareas:
1. Crear la puerta con codigo.
2. Crear e implementar los almohadones movibles.
3. Crear la nota.
4. Permitir colocar la contraseña de 4 digitos.
5. Validar el orden.
6. Desbloquear la puerta.

**Criterio de finalización:** el jugador puede encontrar la nota bajo los almohadones y usar el tablero nomerico para introducir la contraseña.

## Etapa 6 — Tercer puzle

Objetivo: implementar la cocina.

Tareas:
1. Crear la heladera y la lata.
2. Crear la cocina a gas.
3. Crear el fosforo.
4. Permitir encender la cocina con el fosforo.
5. Permitir colocar la lata en el fuego.
6. Detonar la lata para acceder a la llave su interior.

**Criterio de finalización:** el jugador puede recoger la lata y el fosforo e interactuar correctamente con la cocina.

## Etapa 7 — Construcción de la casa

Objetivo: reemplazar el escenario de pruebas por el entorno definitivo.

Tareas:
1. Definir las dimensiones de cada habitación.
2. Construir paredes, suelos y techos.
3. Modelar o importar puertas y ventanas.
4. Incorporar muebles.
5. Distribuir objetos y pistas.
6. Crear el exterior.
7. Revisar colisiones y navegación del jugador.

**Criterio de finalización:** toda la experiencia puede recorrerse dentro de la casa definitiva.

## Etapa 8 — Ambientación y presentación

Objetivo: mejorar la experiencia visual y sonora.

Tareas:
1. Crear materiales.
2. Configurar iluminación.
3. Incorporar sonidos ambientales.
4. Añadir sonidos de puertas, cajones y objetos.
5. Crear animaciones sencillas.
6. Mejorar las interfaces.
7. Añadir pantalla de inicio y finalización.

**Criterio de finalización:** la demo cuenta con una presentación visual y sonora coherente.

## Etapa 9 — Pruebas y entrega

Objetivo: garantizar que la demo pueda completarse sin problemas.

Tareas:
1. Completar la partida desde el inicio.
2. Verificar todos los puzles.
3. Comprobar las cerraduras.
4. Comprobar que los objetos no desaparezcan o queden inaccesibles.
5. Revisar errores de colisión.
6. Probar la resolución y los controles.
7. Exportar una versión ejecutable para PC.
8. Realizar una última prueba utilizando la versión exportada.

**Criterio de finalización:** una persona puede iniciar la demo, resolver los tres puzles y salir de la casa sin intervención del desarrollador.

---

# 7. Criterios generales de calidad

La demo se considerará terminada cuando cumpla con los siguientes puntos:

- [ ] El jugador puede iniciar una partida.
- [ ] El movimiento y la cámara funcionan correctamente.
- [ ] Los objetos interactuables se reconocen visualmente.
- [ ] Las notas y pistas se pueden consultar.
- [ ] El inventario registra los objetos.
- [ ] Las puertas verifican correctamente las llaves.
- [ ] Los tres puzles funcionan.
- [ ] Las recompensas se entregan correctamente.
- [ ] La casa se puede recorrer sin errores.
- [ ] La puerta principal permite salir.
- [ ] Existe una pantalla o secuencia de finalización.
- [ ] La versión exportada funciona correctamente.

---

# 8. Prioridades y administración del tiempo

El orden de prioridad debe ser:

1. **Jugabilidad:** movimiento, interacción y progresión.
2. **Puzles:** las tres pruebas deben funcionar.
3. **Escenario:** la casa debe estar construida y ser explorable.
4. **Presentación:** iluminación, materiales, sonidos y animaciones.
5. **Pulido:** detalles visuales y corrección de errores.

No se debe retrasar la implementación de las mecánicas por intentar conseguir modelos 3D definitivos demasiado pronto.

## Regla principal de desarrollo

Primero construir una versión funcional utilizando geometría básica. Una vez que la experiencia completa pueda jugarse y terminarse, reemplazar los elementos provisionales por modelos definitivos y trabajar en la presentación.

**Resultado esperado:** una demo 3D de escape room pequeña, funcional y presentable, con tres puzles conectados por una progresión de llaves y una condición de victoria clara.
