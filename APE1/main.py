def mostrar_tabla(titulo, filas):
    print("\n=== " + titulo + " ===")
    print("Hora   Hum  Nub  Temp    H     N     Tf    Índice  Estado")
    for f in filas:
        print(f"{f['hora']}  {f['humedad']:4}  {f['nubosidad']:3}  {f['temp']:4}  "
              f"{f['H']:.2f}  {f['N']:.2f}  {f['Tf']:.2f}  {f['I']:.3f}   {f['estado']}")


# GRAFICAS
def grafica_indice(horas, I, titulo, archivo):
    plt.figure(figsize=(10, 5))
    plt.plot(horas, I, marker="o", label="Índice I")
    plt.axhline(y=0.40, linestyle="--", color="green", label="Baja posibilidad (0.40)")
    plt.axhline(y=0.60, linestyle="--", color="orange", label="Lluvia probable (0.60)")
    plt.axhline(y=0.75, linestyle="--", color="red", label="Lluvia (0.75)")
    plt.xlabel("Hora")
    plt.ylabel("Índice de lluvia")
    plt.title(titulo)
    plt.grid(True)
    plt.legend()
    plt.savefig(archivo)   # guarda la imagen para el portafolio
    plt.show()


def grafica_variables(horas, H, N, Tf, I, titulo, archivo):
    plt.figure(figsize=(10, 5))
    plt.plot(horas, H, marker="o", label="H (humedad)")
    plt.plot(horas, N, marker="s", label="N (nubosidad)")
    plt.plot(horas, Tf, marker="^", label="Tf (factor temperatura)")
    plt.plot(horas, I, marker="d", linewidth=3, color="black", label="Índice I")
    plt.xlabel("Hora")
    plt.ylabel("Valor normalizado")
    plt.title(titulo)
    plt.grid(True)
    plt.legend()
    plt.savefig(archivo)
    plt.show()


def grafica_comparacion(horas, I1, I2, archivo):
    plt.figure(figsize=(10, 5))
    plt.plot(horas, I1, marker="o", label="Modelo original")
    plt.plot(horas, I2, marker="s", label="Modelo ajustado")
    plt.axhline(y=0.75, linestyle="--", color="red", label="Umbral de lluvia (0.75)")
    plt.xlabel("Hora")
    plt.ylabel("Índice de lluvia")
    plt.title("Comparación del modelo original y el ajustado")
    plt.grid(True)
    plt.legend()
    plt.savefig(archivo)
    plt.show()



# Programa principal

controlador = Controlador()
tabla1 = controlador.calcular_tabla(controlador.original)
tabla2 = controlador.calcular_tabla(controlador.ajustado)

mostrar_tabla(controlador.original.nombre, tabla1)
mostrar_tabla(controlador.ajustado.nombre, tabla2)

# Lista para graficar
horas = [f["hora"] for f in tabla1]
H1 = [f["H"] for f in tabla1]
N1 = [f["N"] for f in tabla1]
Tf1 = [f["Tf"] for f in tabla1]
I1 = [f["I"] for f in tabla1]
H2 = [f["H"] for f in tabla2]
N2 = [f["N"] for f in tabla2]
Tf2 = [f["Tf"] for f in tabla2]
I2 = [f["I"] for f in tabla2]

grafica_indice(horas, I1, "Índice de lluvia - modelo original", "resultados/indice_original.png")
grafica_variables(horas, H1, N1, Tf1, I1, "Variables - modelo original", "resultados/variables_original.png")
grafica_indice(horas, I2, "Índice de lluvia - modelo ajustado", "resultados/indice_ajustado.png")
grafica_variables(horas, H2, N2, Tf2, I2, "Variables - modelo ajustado", "resultados/variables_ajustado.png")
grafica_comparacion(horas, I1, I2, "resultados/comparacion.png")
