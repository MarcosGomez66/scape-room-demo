# cosas que hacer
## puzle 1

- [Hecho] crear la escena del ropero:
	- se debe poder interactuar con la puerta izquierda para abrir
	- al abrir la puerta del ropero dejarla siempre abierta a 90 grados (bloquear interaccion)
	- se debe poder interactuar con la puerta de la caja fuerte dentro del ropero para desplegar la ventana del puzle
	- una vez resuelto el puzle dejar la puerta de la caja fuerte siempre abierta a 90 grados (tambien bloquear interaccion)
	- en el espacio de la caja fuerte se debe poder instanciar la llave de la habitacion
	
- [Hecho] crear la ventana (control) para el puzle de la caja fuerte:
	- una fila que contenga un label "Caja fuerte" en la izquierda y un boton para cerrar a la derecha
	- una fila de 5 cuadrados que representen unos foquitos de luz roja para indicar el boton que ya fue presionado
	- una fila de 5 botones circulos de colores (de izquierda a derecha: magenta, amarillo, azul, rojo, verde)
	- se pueden pulsar un maximo de 3 botones
	- al pulsar 3 botones incorrectamente se reinicia el estado del puzle y se aplica la penalizacion
	- al pulsar los botones correspondientes se abre la puerta

- [Hecho] crear la escena del escritorio:
	- se debe poder interactuar con el escritorio para extraer el cajon
	- crear un plano blanco para representar el papel dentro del cajon
	- al extraer el cajon se debe poder ver e interactuar con la nota dentro del cajon
	- al interactuar con la nota se debe desplegar la ventana de la nota

- [Hecho] crear la ventana (control) de la nota:
	- un fondo blanco para representar el papel
	- columna de 3 labels para las pistas 

- [Hecho] crear la escena para los cuadros:
	- el cuadro debe tener un espacio para asignar la imagen correspondiente al instanciar
	
- [Hecho] crear el sistema del puzle, su generacion aleatoria que se ejecuta al iniciar el juego:
	- seleccionar aleatoriamente tres colores de los 5 posibles sin repetir (magenta, amarillo, azul, rojo, verde) y el orden de estos
	- asignar correctamente la imagen a los 3 cuadros de la escena segun los colores correctos (no importa el orden)
	- asignar en la nota las leyendas correspondientes segun cada color y orden
	- asignar la combinacion a la escena del ropero y crear el sistema de comprobacion
	- modificar la escena house_test_level para agregar los objetos necesarios
	- comprobar que los colores pulsados y el orden sea correcto
	- permitir obtener la llave al presionar correctamente los botones
	
- [Hecho] crear sistema de penalizacion:
	- cada vez que se ingrese una combinacion incorrecta el jugador recibe un strike
	- tres strikes finaliza el juego

# Pistas
## Orquidea_magenta
Elegancia simétrica de pétalos delicados sobre tallos firmes.

## Taxi_amarillo
Un bólido urbano cruzando el asfalto caótico.

## Globo_azul
El mundo entero girando suavemente en una esfera de escritorio.

## Telefono_rojo
Una centinela de hierro en la acera que guarda voces perdidas.

## Cactus_verde
una fortaleza viviente de espinas y pliegues que desafía la sequedad.

## puzle 2

- [Hecho] crear la escena del sofa:
	- con static body lo suficientemente detallado para instanciar encima la tarjeta y las almohadas
	
- [Hecho] crear la escena de la almohada y la tarjeta:
	- la almohada se debe poder recoger con E
	- la tarjeta es un plano con la imagen correspondiente en una cara
	- la tarjeta solo se puede ver, no recoger
	- al interactuar con la tarjeta se despliega su ventana igual que la nota
	
- [Hecho] crear la ventana de la tarjeta:
	- se muestra un panel con la imagen correspondiente
	
- [Hecho] implementar dos cambios al inventario y sistema de traslado de objetos:
	- mostrar el objeto seleccionado en la vista del jugador como si lo llevara en la mano
	- permitir soltar el objeto con F

- [Hecho] crear la escena de la cerradura numerica:
	- con un var export password: int = 2805
	- se debe poder interactuar con la cerradura
	- al interactuar se debe mostrar la ventana de la cerradura numerica
	
- [Hecho] crear ventana de la cerradura:
	- una fila que contenga un label "Cerradura" en la izquierda y un boton para cerrar a la derecha
	- una fila con un label que muestra los numeros presionados
	- una fila con los botones "X" (para reiniciar), "0" y "✓" (para comprobar)
	- una fila con "1", "2" y "3"
	- una fila con "4", "5" y "6"
	- una fila con "7", "8" y "9"
	- si se introduce un codigo incorrecto se suma un strike (los strikes son globales, no por puzle) y se reinicia
	- si se introduce el codigo correcto se desbloquea la puerta vinculada

- [Hecho] crear el sistema del segundo puzle:
	- sobre el sofa se crean 3 lugares donde puede estar la tarjeta
	- en cada lugar tambien debe ir una almohada encima
	- la idea es que el jugador deba recoger y soltar las almohadas hasta revelar la tarjeta debajo
	- modificar house_test_level para colocar los objetos del segundo puzle
	- la puerta se abre hacia la cocina
	- colocar la cerradura numerica al lado de la puerta
	- comprobar que la contraseña sea la correcta para desbloquear la puerta

## puzle 3

- [Hecho] crear la escena de la heladera:
	- se debe poder interactuar con la puerta para abrir, dejar abierto
	- en su interior se debe poder instanciar una nota en la primera parrilla y la lata en la segunda

- [Hecho] crear la lata de alimento, la nota, el fosforo, la llave del baño y la llave principal:
	- la lata se debe poder recoger
	- el fosforo se debe poder recoger
	- la nota solo muestra la ventana con el texto "No poner la lata de alimento directamente en el fuego"

- [Hecho] crear la escena de la cocina:
	- se debe poder interactuar con la cocina, originalmente apagada
	- interactuar con la lata seleccionada ubica la lata encima de la hornalla 002
	- interactuar con la caja de fosforos enciende la cocina
	- intaructuar con otra cosa o sin nada muestra un mensaje explicativo "La cocina tiene gas pero necesito algo para encenderlo"

- [Hecho] crear la escena de la mesita:
	- con dos simples usos, sostener la llave del baño en la cocina y sostener los fosforos en el baño

- [Hecho] crear el sistema del tercer puzle:
	- colocar y vincular la puerta del baño y la puerta principal con sus respectivas llaves (si se puede reemplazar el color del materiar de la hoja de la puerta principal por uno blanco para que se diferencie de las otras puertas)
	- colocar la heladera, la cocina a gas y la mesita (con la llave del baño arriba) en la cocina
	- colocar la mesita (con la caja de fosforos) en el fondo del baño
	- ubicar la lata y encender la cocina deben poder funcionar por separado sin orden
	- cuando la lata este en posicion con la cocina encendida inciar un cronometro de 5 segundos
	- durante transcurre el cronometro aplicar una animacion de vibracion a la lata, tambien bloquear la interaccion con la cocina
	- al finalizar el cronometro simular que la tapa de la lata sale disparada hacia arriba
	- al final se debe poder recoger la llave principal instanciada dentro de la lata dentro de la lata

- [Hecho] crear el sistema de fin del juego:
	- que muestre un mensaje de felicitaciones y un boton de reinicio
