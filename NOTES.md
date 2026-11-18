# cosas que hacer
- crear la escena del ropero:
	- se debe poder interactuar con la puerta izquierda para abrir
	- al abrir la puerta del ropero dejarla siempre abierta a 90 grados (bloquear interaccion)
	- se debe poder interactuar con la puerta de la caja fuerte dentro del ropero para desplegar la ventana del puzle
	- una vez resuelto el puzle dejar la puerta de la caja fuerte siempre abierta a 90 grados (tambien bloquear interaccion)
	- en el espacio de la caja fuerte se debe poder instanciar la llave de la habitacion
	
- crear la ventana (control) para el puzle de la caja fuerte:
	- una fila que contenga un label "Caja fuerte" en la izquierda y un boton para cerrar a la derecha
	- una fila de 5 cuadrados que representen unos foquitos de luz roja para indicar el boton que ya fue presionado
	- una fila de 5 botones circulos de colores (de izquierda a derecha: magenta, amarillo, azul, rojo, verde)
	- se pueden pulsar un maximo de 3 botones
	- al pulsar 3 botones incorrectamente se reinicia el estado del puzle y se aplica la penalizacion
	- al pulsar los botones correspondientes se abre la puerta

- crear la escena del escritorio:
	- se debe poder interactuar con el escritorio para extraer el cajon
	- crear un plano blanco para representar el papel dentro del cajon
	- al extraer el cajon se debe poder ver e interactuar con la nota dentro del cajon
	- al interactuar con la nota se debe desplegar la ventana de la nota

- crear la ventana (control) de la nota:
	- un fondo blanco para representar el papel
	- columna de 3 labels para las pistas 

- crear la escena para los cuadros:
	- el cuadro debe tener un espacio para asignar la imagen correspondiente al instanciar
	
- crear el sistema del puzle, su generacion aleatoria que se ejecuta al iniciar el juego:
	- seleccionar aleatoriamente tres colores de los 5 posibles sin repetir (magenta, amarillo, azul, rojo, verde) y el orden de estos
	- asignar correctamente la imagen a los 3 cuadros de la escena segun los colores correctos (no importa el orden)
	- asignar en la nota las leyendas correspondientes segun cada color y orden
	- asignar la combinacion a la escena del ropero y crear el sistema de comprobacion
	- modificar la escena house_test_level para agregar los objetos necesarios
	- comprobar que los colores pulsados y el orden sea correcto
	- permitir obtener la llave al presionar correctamente los botones
	
- crear sistema de penalizacion:
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
