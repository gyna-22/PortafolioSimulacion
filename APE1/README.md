# Simulación climática: índice de probabilidad de lluvia

Modelo de simulación que estima la probabilidad de lluvia a partir de la humedad, la nubosidad y la temperatura registradas a lo largo del día. El proyecto compara un **modelo original** con un **modelo ajustado** y genera tablas y gráficas de resultados.

## Descripción general

El programa procesa una serie de observaciones horarias (de 06:00 a 22:00) y calcula para cada una un **índice de lluvia** `I` en el rango `[0, 1]`. A partir de ese índice se clasifica el estado del clima en cuatro categorías.

La lógica está separada en tres archivos:

| Archivo | Responsabilidad |
| --- | --- |
| `modelo.py` | Define los datos de entrada, el cálculo del índice y su clasificación. |
| `controlador.py` | Crea los modelos original y ajustado, y construye las tablas de resultados. |
| `main.py` | Ejecuta la simulación, imprime las tablas y genera las gráficas. |

El modelo original prioriza la humedad (`0.5H`), mientras que el modelo ajustado equilibra humedad y nubosidad (`0.4H + 0.4N`), lo que permite comparar el efecto de los pesos en el índice final.

## Fórmula matemática

Cada variable de entrada se normaliza al intervalo `[0, 1]`:

$$
H = \frac{\text{humedad}}{100}, \qquad N = \frac{\text{nubosidad}}{100}
$$

El factor de temperatura `Tf` reduce la probabilidad de lluvia a medida que la temperatura aumenta:

$$
T_f(T) =
\begin{cases}
1.0, & T \le 10 \\
1.0 - 0.05\,(T - 10), & 10 < T < 28 \\
0.1, & T \ge 28
\end{cases}
$$

El índice de lluvia es una combinación lineal ponderada:

$$
I = aH + bN + cT_f
$$

Donde `a`, `b` y `c` son los pesos de cada variable. El proyecto evalúa dos configuraciones:

| Modelo | Pesos `(a, b, c)` | Expresión |
| --- | --- | --- |
| Original | `(0.5, 0.3, 0.2)` | `I = 0.5H + 0.3N + 0.2Tf` |
| Ajustado | `(0.4, 0.4, 0.2)` | `I = 0.4H + 0.4N + 0.2Tf` |

### Clasificación del estado

| Rango del índice | Estado |
| --- | --- |
| `I < 0.40` | Sin lluvia |
| `0.40 ≤ I < 0.60` | Baja posibilidad |
| `0.60 ≤ I < 0.75` | Lluvia probable |
| `I ≥ 0.75` | Lluvia |

## Requisitos previos

- **Python 3.8 o superior**
- **matplotlib** para la generación de gráficas

Instalación de la dependencia:

```bash
pip install matplotlib
```

No se requieren librerías adicionales ni archivos de configuración.

## Instrucciones de uso

1. Clona el repositorio y entra al directorio del proyecto:

   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd PortafolioSimulacion/APE1
   ```

2. Ejecuta el programa principal:

   ```bash
   python main.py
   ```

   Es importante ejecutarlo desde la carpeta `APE1`, ya que las gráficas se guardan con rutas relativas.

3. El programa mostrará en la terminal las tablas de ambos modelos y abrirá las gráficas en pantalla. Además, guardará las imágenes en `resultados/`:

   - `indice_original.png`
   - `indice_ajustado.png`
   - `variables_original.png`
   - `variables_ajustado.png`
   - `comparacion.png`

> **Nota:** si tu copia de `main.py` no incluye las importaciones `import matplotlib.pyplot as plt` y `from controlador import Controlador`, agrégalas al inicio del archivo antes de ejecutarlo.

## Datos de entrada

Las observaciones se definen en `modelo.py` dentro de la lista `DATOS`, con el formato `(hora, humedad %, nubosidad %, temperatura °C)`:

```python
DATOS = [
    ("06:00", 65, 40, 14),
    ("08:00", 70, 50, 16),
    # ...
]
```

Para simular otro escenario, edita esta lista o los pesos de los modelos en `controlador.py`.

## Resultados

Las gráficas generadas permiten:

- Visualizar la evolución horaria del índice de lluvia y de sus variables normalizadas.
- Comparar el modelo original con el ajustado frente al umbral de lluvia (`0.75`).

El análisis completo se encuentra en el informe [`APE1_Reporte.pdf`](./APE1_Reporte.pdf).
