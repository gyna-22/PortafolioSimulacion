# Modelo SIR en NetLogo

Simulación SIR por agentes (NetLogo 7.0.4) con los parámetros comunes de la APE 4: población 100,
5 infectados iniciales, β = 0.30, γ = 0.10, 100 ticks. Además importa `resultados_python.csv`
(generado por Python/SimPy) para graficarlo y compararlo con la corrida de NetLogo.

## Archivos

| Archivo | Descripción |
| --- | --- |
| `modelo_sir_netlogo.nlogox` | Modelo en el formato nativo de NetLogo 7 (XML). Es la fuente principal. |
| `modelo_sir_netlogo.nlogo` | El mismo modelo en formato clásico, con el nombre que usa la guía. NetLogo 7.0.4 también lo abre. |
| `resultados_netlogo.csv` | Salida de NetLogo (contrato de la guía: `tiempo,susceptibles,infectados,recuperados`, 101 filas). |
| `resultados_python.csv` | Entrada que lee el botón VER PYTHON (la genera la parte de Python). |

## Uso en la interfaz

1. Abrir el modelo con NetLogo (el CSV de Python debe estar en esta misma carpeta).
2. (Opcional) cambiar la **semilla** para repetir o variar la corrida.
3. **SIMULAR Y COMPARAR**: corre NetLogo hasta el tick 100, carga `resultados_python.csv` y dibuja
   automáticamente los tres gráficos comparativos (infectados, susceptibles y recuperados).
4. **VER PYTHON**: recarga el CSV y muestra su tick 0 sobre las tortugas.
5. **ANIMAR PYTHON**: recorre la serie de Python; vuelve a presionarlo para detenerlo. Para repetir,
   usa **VER PYTHON** y luego **ANIMAR PYTHON**.
6. **EXPORTAR CSV**: guarda la corrida de NetLogo en `resultados_netlogo.csv`.

El monitor **Estado** muestra el pico de infectados y su instante para las dos herramientas. Como el CSV
solo guarda conteos, al animarlo los colores son una reconstrucción visual de S, I y R, no las identidades
de la corrida original.

## Ejecución sin interfaz (BehaviorSpace)

El modelo incluye el experimento `ejecucion-completa` (SETUP, GO hasta el tick 100 y exportación del CSV).
Ajusta las rutas a tu instalación de NetLogo; por ejemplo:

```bash
export JAVA_HOME=/opt/NetLogo-7.0.4/lib/runtime
/opt/NetLogo-7.0.4/netlogo-headless.sh --model modelo_sir_netlogo.nlogox \
  --experiment ejecucion-completa --table /tmp/tabla_netlogo.csv
```

Con la semilla 42: pico de infectados 31 en el tick 17 y 93 recuperados finales; una corrida tarda unos 3 s.

## Notas

- Mismo modelo en ambos formatos: si se edita uno, hay que volver a guardar el otro desde NetLogo (Archivo → Guardar como).
- El fin de línea del CSV exportado es siempre `\n` (se escribe con `file-type` y `"\n"` explícito).
