# APE2 - Simulación de Crecimiento Poblacional

Proyecto en Python que compara distintos modelos matemáticos de crecimiento
poblacional (determinístico, discreto, estocástico y continuo aproximado por
Euler) a partir de un conjunto de datos observados, y genera gráficas para
analizar la influencia de la tasa de crecimiento `r` y del nivel de ruido `σ`.

## Descripción general

El programa estima la tasa de crecimiento a partir de los datos observados y
ejecuta cuatro modelos sobre el mismo horizonte temporal. Luego produce tres
gráficas:

1. **Comparativa de modelos** frente a los datos observados.
2. **Influencia de la tasa `r`** (incluye crecimiento y decrecimiento).
3. **Efecto del ruido `σ`** en el modelo estocástico.

Los resultados se guardan por defecto en la carpeta `resultados/`:

- `comparativa_modelos.png`
- `influencia_r.png`
- `efecto_ruido.png`

## Fórmulas matemáticas empleadas

Datos observados base:

```
[1000, 1100, 1250, 1400, 1600, 1850, 2100]
```

### 1. Modelo determinístico (exponencial continuo)

```
P(t) = P0 · e^(r·t)
```

### 2. Modelo discreto

```
P(t+1) = P(t) + r · P(t) = P(t) · (1 + r)
```

### 3. Modelo estocástico

```
P(t+1) = P(t) + r · P(t) + ε,    ε ~ N(0, σ²)
```

Se aplica la restricción `P(t+1) = max(P(t+1), 0)` para evitar poblaciones
negativas.

### 4. Modelo continuo aproximado por Euler

Partiendo de la ecuación diferencial:

```
dP/dt = r · P
```

se aproxima con el método de Euler de paso `dt`:

```
P(t + dt) = P(t) + dt · r · P(t)
```

### Estimación de la tasa de crecimiento `r`

```
r = ln(Pn / P0) / n
```

donde `n` es el número de intervalos entre el primer y el último dato.

### Error del modelo (RMSE)

```
RMSE = sqrt( (1/N) · Σ (P_modelo(t_i) - P_dato(t_i))² )
```

## Estructura del proyecto

```
APE2/
├── main.py                      # Punto de entrada
├── requirements.txt             # Dependencias
├── controlador/
│   └── controlador.py           # Orquesta la simulación
├── modelo/
│   └── modelos.py               # Modelos y funciones matemáticas
├── vista/
│   └── vista_grafica.py         # Generación de gráficas
└── resultados/                  # Imágenes generadas
```

## Requisitos previos

- Python 3.10 o superior (el código usa anotaciones como `int | None`).
- `pip` para instalar dependencias.

Dependencias (ver `requirements.txt`):

- `numpy`
- `matplotlib`

## Instrucciones de uso

1. (Opcional) Crear y activar un entorno virtual:

   ```bash
   python -m venv .venv
   source .venv/bin/activate        # Linux / macOS
   # .venv\Scripts\activate         # Windows
   ```

2. Instalar las dependencias:

   ```bash
   pip install -r requirements.txt
   ```

3. Ejecutar el programa desde la raíz del proyecto:

   ```bash
   python main.py
   ```

4. Al finalizar, se mostrarán las gráficas en pantalla y se guardarán las
   imágenes en la carpeta `resultados/`.

### Ejecución sin ventanas (modo servidor)

Para generar solo los archivos sin abrir ventanas, se puede modificar `main.py`
y usar `mostrar=False`:

```python
from controlador.controlador import ControladorSimulacion
from vista.vista_grafica import VistaGrafica

grafica = VistaGrafica(carpeta_salida="resultados", mostrar=False)
ControladorSimulacion(grafica).ejecutar()
```

### Uso de datos propios

`ControladorSimulacion` acepta una lista de datos observados opcional:

```python
from controlador.controlador import ControladorSimulacion
from vista.vista_grafica import VistaGrafica

datos = [500, 620, 780, 990, 1250]
ControladorSimulacion(VistaGrafica(carpeta_salida="resultados"), datos=datos).ejecutar()
```

Los parámetros de la simulación (`sigma`, `dt`, `tiempo`, `semilla`) se definen
en el constructor de `ControladorSimulacion` y pueden ajustarse según el
experimento.

## Notas

- El modelo estocástico usa una semilla fija (`semilla=42`) para que los
  resultados sean reproducibles.
- El paso de Euler por defecto es `dt=0.1`.
- El nivel de ruido por defecto es `σ=50`.
