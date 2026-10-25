;; Modelo SIR por agentes (APE 4: comparación de herramientas).
;; Versión simplificada: un botón simula y compara, y otro reproduce la
;; serie de Python sobre los agentes. Parámetros fijos de la práctica:
;; población 100, 5 infectados iniciales, beta = 0.30, gamma = 0.10,
;; 100 ticks. La semilla sí es configurable.

extensions [ csv ]

globals [
  ;; Serie de la simulación de NetLogo (t = 0..100)
  net-t net-s net-i net-r
  ;; Serie importada de resultados_python.csv
  py-t py-s py-i py-r
  ;; Reproducción de la serie de Python sobre los agentes
  py-index py-mode?
  ;; Mensaje del monitor Estado
  status
]

turtles-own [
  state       ;; 0 = susceptible, 1 = infectado, 2 = recuperado
  next-state  ;; copia para la actualización síncrona
]

;; ---------------------------------------------------------------------
;; Simulación de NetLogo
;; ---------------------------------------------------------------------

to setup
  ;; No se usa clear-all porque reiniciaría la semilla.
  clear-turtles
  clear-drawing
  clear-all-plots
  clear-output
  set net-t []
  set net-s []
  set net-i []
  set net-r []
  set py-t []
  set py-s []
  set py-i []
  set py-r []
  set py-index 0
  set py-mode? false
  random-seed seed
  create-turtles 100 [
    setxy random-xcor random-ycor
    set shape "circle"
    set size 1.5
    set state 0
    set next-state 0
  ]
  ask n-of 5 turtles [ set state 1 ]
  paint-turtles
  reset-ticks
  record-state
  set status "Listo: presiona SIMULAR Y COMPARAR."
end

;; Un paso de la simulación de NetLogo.
to go
  if ticks >= 100 [ stop ]
  step
  tick
  record-state
  paint-turtles
end

;; Regla común: cada infectado contacta a un individuo al azar y luego
;; puede recuperarse. Todo se decide con el estado del inicio del tick.
to step
  ask turtles [ set next-state state ]
  ask turtles with [ state = 1 ] [
    let contact one-of other turtles
    if contact != nobody [
      if [ state ] of contact = 0 and random-float 1 < 0.30 [
        ask contact [ set next-state 1 ]
      ]
    ]
    if random-float 1 < 0.10 [ set next-state 2 ]
  ]
  ask turtles [ set state next-state ]
  ;; Movimiento solo visual: el contagio no depende de la posición.
  ask turtles [
    rt random 360
    fd 0.5
  ]
end

to paint-turtles
  ask turtles [
    set color ifelse-value (state = 0) [ green ] [ ifelse-value (state = 1) [ red ] [ gray ] ]
  ]
end

to record-state
  set net-t lput ticks net-t
  set net-s lput count turtles with [ state = 0 ] net-s
  set net-i lput count turtles with [ state = 1 ] net-i
  set net-r lput count turtles with [ state = 2 ] net-r
end

;; ---------------------------------------------------------------------
;; Flujo principal: simular NetLogo y comparar con Python
;; ---------------------------------------------------------------------

to simulate-and-compare
  setup
  while [ticks < 100] [ go ]
  load-python
  draw-comparison-plots
  ifelse empty? py-t [
    set status (word "NetLogo: pico " peak-value net-i " (t=" peak-tick net-t net-i "). No se encontró resultados_python.csv.")
  ] [
    set status (word "Pico NetLogo " peak-value net-i " (t=" peak-tick net-t net-i ") | Pico Python " peak-value py-i " (t=" peak-tick py-t py-i ")")
  ]
end

to draw-comparison-plots
  init-lists
  draw-comparison "Infectados: NetLogo vs Python" py-t py-i net-t net-i
  draw-comparison "Susceptibles: NetLogo vs Python" py-t py-s net-t net-s
  draw-comparison "Recuperados: NetLogo vs Python" py-t py-r net-t net-r
end

to draw-comparison [ plot-title xs-py ys-py xs-net ys-net ]
  draw-series plot-title "Python" xs-py ys-py
  draw-series plot-title "NetLogo" xs-net ys-net
end

to draw-series [ plot-title pen-name xs ys ]
  set-current-plot plot-title
  set-current-plot-pen pen-name
  plot-pen-reset
  ;; Pluma levantada hasta el primer punto para no trazar desde el origen.
  plot-pen-up
  (foreach xs ys [ [ x y ] ->
    plotxy x y
    plot-pen-down
  ])
end

;; Valor máximo de infectados de una serie (0 si no hay datos).
to-report peak-value [ ys ]
  report ifelse-value empty? ys [ 0 ] [ max ys ]
end

;; Tick en que ocurre el pico de infectados ("-" si no hay datos).
to-report peak-tick [ xs ys ]
  report ifelse-value empty? ys [ "-" ] [ item (position max ys ys) xs ]
end

;; ---------------------------------------------------------------------
;; Importación de resultados de Python
;; ---------------------------------------------------------------------

to load-python
  init-lists
  let data read-series "resultados_python.csv"
  if not empty? data [
    set py-t item 0 data
    set py-s item 1 data
    set py-i item 2 data
    set py-r item 3 data
    set py-index 0
    set py-mode? false
  ]
end

to init-lists
  if not is-list? py-t [ set py-t [] set py-s [] set py-i [] set py-r [] ]
  if not is-list? net-t [ set net-t [] set net-s [] set net-i [] set net-r [] ]
end

;; Lee el CSV y reporta [tiempo susceptibles infectados recuperados].
to-report read-series [ file-name ]
  if not file-exists? file-name [
    set status (word "No se encontró " file-name " en la carpeta del modelo")
    report []
  ]
  let t []
  let s []
  let i []
  let r []
  file-open file-name
  let header file-read-line
  if header != "tiempo,susceptibles,infectados,recuperados" [
    file-close
    set status (word "Encabezado inválido en " file-name)
    report []
  ]
  while [ not file-at-end? ] [
    let line file-read-line
    if length line > 0 [
      let row csv:from-row line
      if length row = 4 [
        set t lput item 0 row t
        set s lput item 1 row s
        set i lput item 2 row i
        set r lput item 3 row r
      ]
    ]
  ]
  file-close
  report (list t s i r)
end

;; ---------------------------------------------------------------------
;; Reproducción de la serie de Python sobre los agentes
;; ---------------------------------------------------------------------

;; Recarga el CSV y muestra su tick 0 sobre las tortugas.
to view-python
  load-python
  if empty? py-t [ stop ]
  let total ((item 0 py-s) + (item 0 py-i) + (item 0 py-r))
  if count turtles != total [
    clear-turtles
    create-turtles total [
      setxy random-xcor random-ycor
      set shape "circle"
      set size 1.5
      set state 0
      set next-state 0
    ]
  ]
  set py-index 0
  set py-mode? true
  apply-python-state
end

;; Un paso de la animación; el botón ANIMAR PYTHON lo llama en cada frame.
to animate-python
  ifelse not py-mode? [
    view-python
  ] [
    if empty? py-t [ stop ]
    if py-index >= (length py-t - 1) [
      set status "Reproducción de Python terminada. Usa VER PYTHON para repetir."
      stop
    ]
    set py-index py-index + 1
    apply-python-state
  ]
end

;; El CSV solo guarda conteos, no identidades. La asignación es una
;; reconstrucción visual: primero S, luego I y al final R.
to apply-python-state
  let s item py-index py-s
  let i item py-index py-i
  let r item py-index py-r
  ask turtles [
    ifelse who < s [
      set state 0
    ] [
      ifelse who < (s + i) [ set state 1 ] [ set state 2 ]
    ]
    set next-state state
  ]
  paint-turtles
  set status (word "Python: t = " item py-index py-t " | S " s " I " i " R " r)
end

;; ---------------------------------------------------------------------
;; Exportación de la serie de NetLogo
;; ---------------------------------------------------------------------

to export-netlogo
  init-lists
  if empty? net-t [
    set status "Nada que exportar: primero usa SIMULAR Y COMPARAR."
    stop
  ]
  let file-name "resultados_netlogo.csv"
  if file-exists? file-name [ file-delete file-name ]
  file-open file-name
  ;; file-type con "\n" explícito garantiza fin de línea LF en cualquier sistema.
  file-type "tiempo,susceptibles,infectados,recuperados\n"
  (foreach net-t net-s net-i net-r [ [ t s i r ] ->
    file-type (word t "," s "," i "," r "\n")
  ])
  file-close
  set status (word "Exportado " file-name " (" length net-t " filas)")
end

@#$#@#$#@
GRAPHICS-WINDOW
10
10
390
380
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
10
390
210
440
SIMULAR Y COMPARAR
simulate-and-compare
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
220
390
300
440
VER PYTHON
view-python
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
310
390
390
440
ANIMAR PYTHON
animate-python
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
10
450
190
500
EXPORTAR CSV
export-netlogo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
200
450
320
500
seed
42.0
1
0
Number

MONITOR
10
510
390
570
Estado
status
0
1
11

PLOT
400
10
820
240
Infectados: NetLogo vs Python
tiempo
individuos
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Python" 1.0 0 -13345367 true "" ""
"NetLogo" 1.0 0 -8630108 true "" ""

PLOT
400
250
820
480
Susceptibles: NetLogo vs Python
tiempo
individuos
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Python" 1.0 0 -13345367 true "" ""
"NetLogo" 1.0 0 -8630108 true "" ""

PLOT
400
490
820
720
Recuperados: NetLogo vs Python
tiempo
individuos
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Python" 1.0 0 -13345367 true "" ""
"NetLogo" 1.0 0 -8630108 true "" ""

@#$#@#$#@
## ¿QUÉ ES?

Modelo epidemiológico SIR (Susceptible – Infectado – Recuperado) por agentes, parte de la APE 4 de Simulación (UNL). NetLogo ejecuta su propia simulación y además importa el CSV generado por Python/SimPy para comparar ambas corridas.

## CÓMO USARLO

1. (Opcional) cambia la **semilla** para repetir o variar la corrida.
2. **SIMULAR Y COMPARAR**: corre NetLogo hasta el tick 100, carga `resultados_python.csv` y dibuja las tres comparaciones.
3. **VER PYTHON**: recarga el CSV y muestra su tick 0 sobre las tortugas.
4. **ANIMAR PYTHON**: recorre la serie de Python; vuelve a presionarlo para detenerlo. Para repetir, usa **VER PYTHON** y luego **ANIMAR PYTHON**.
5. **EXPORTAR CSV**: guarda la corrida de NetLogo en `resultados_netlogo.csv`.

El monitor **Estado** muestra el pico de infectados y su instante para las dos herramientas. El modelo debe estar en la misma carpeta que los CSV.

## PARÁMETROS FIJOS

Población 100, 5 infectados iniciales, beta = 0.30, gamma = 0.10 y 100 ticks. La regla es la misma en las dos herramientas: cada infectado elige un contacto al azar; si es susceptible y `random < beta` se contagia, y luego se recupera si `random < gamma`. La actualización es síncrona.

## GRÁFICOS

Tres gráficos comparan NetLogo (una curva) con Python (otra curva): infectados, susceptibles y recuperados.

## COSAS PARA NOTAR

Las curvas se parecen pero no son idénticas porque cada herramienta usa su propio generador de números aleatorios. El CSV de Python solo guarda conteos, así que al animarlo los colores son una reconstrucción visual de S, I y R, no las mismas personas de la corrida original.

## EXPERIMENTO (BehaviorSpace)

El experimento `ejecucion-completa` ejecuta SETUP, GO hasta el tick 100 y EXPORTAR CSV sin interfaz gráfica.

## CRÉDITOS

Modelo elaborado para la asignatura Simulación (UNL). NetLogo: Wilensky, U. (1999). NetLogo. Center for Connected Learning and Computer-Based Modeling, Northwestern University.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 7.0.4
@#$#@#$#@
setup repeat 20 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="ejecucion-completa" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <postRun>export-netlogo</postRun>
    <metric>peak-value net-i</metric>
    <metric>peak-tick net-t net-i</metric>
    <metric>last net-r</metric>
    <enumeratedValueSet variable="seed">
      <value value="42"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
