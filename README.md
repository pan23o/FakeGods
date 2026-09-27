# FakeGods

Prototipo inicial de un roguelike de acción en Godot 4. El objetivo completo es ascender por diez niveles, derrotar al jefe de cada uno y volver al templo tras morir. En el templo se conserva la esencia y se puede mejorar permanentemente la vida.

## Probar

1. Abre `project.godot` con Godot 4.2 o posterior.
2. Ejecuta el proyecto con F6/F5 o el botón de reproducir.
3. En el templo, pulsa **E** para comenzar una ascensión.
4. Muévete con **WASD** o las flechas. Ataca con **espacio** o el botón izquierdo del ratón.
5. Derrota a los tres enemigos de la arena. Si mueres, volverás al templo.
6. En el templo, pulsa **U** para mejorar la vida si tienes 3 de esencia.

## Controles

- **WASD / flechas:** movimiento
- **Espacio / clic izquierdo:** ataque cuerpo a cuerpo
- **E:** entrar en la arena o volver al templo al despejarla
- **U:** comprar una mejora permanente de vida en el templo (cuesta 3 de esencia)
- **Esc:** salir

## Estructura

- `scenes/main.tscn`: escena de entrada.
- `scripts/game.gd`: arena, oleada y transición templo/combate.
- `scripts/player.gd`: movimiento, ataque y vida del jugador.
- `scripts/enemy.gd`: enemigo básico de prueba.
- `scripts/run_data.gd`: esencia y mejoras guardadas en `user://fakegods_save.json`.

La primera versión cubre solo el bucle de juego básico. Los diez niveles y sus jefes quedan para iteraciones posteriores.
