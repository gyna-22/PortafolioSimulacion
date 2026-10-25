import os
import matplotlib.pyplot as plt


class VistaGrafica:
    def __init__(self, carpeta_salida: str | None = None, mostrar: bool = True):
        self.carpeta = carpeta_salida
        self.mostrar = mostrar
        if carpeta_salida:
            os.makedirs(carpeta_salida, exist_ok=True)

    def _finalizar(self, fig, nombre: str) -> None:
        if self.carpeta:
            ruta = os.path.join(self.carpeta, nombre)
            fig.savefig(ruta, dpi=150, bbox_inches="tight")
            print(f"  Gráfica guardada en {ruta}")
        if self.mostrar:
            plt.show()
        plt.close(fig)

    @staticmethod
    def _decorar(ax, titulo: str) -> None:
        ax.set_title(titulo)
        ax.set_xlabel("Tiempo")
        ax.set_ylabel("Población")
        ax.legend()
        ax.grid(True, alpha=0.3)

    def graficar_comparativa(self, resultados, datos) -> None:
        fig, ax = plt.subplots(figsize=(9, 5.5))
        estilos = {"Determinístico": "-", "Discreto": "--",
                   "Estocástico": "-", "Continuo (Euler)": ":"}
        for r in resultados:
            ax.plot(r.tiempo, r.poblacion, estilos.get(r.nombre, "-"),
                    label=r.nombre, linewidth=2)
        ax.scatter(range(len(datos)), datos, color="black", zorder=5,
                   label="Datos observados")
        self._decorar(ax, "Comparación de modelos de crecimiento poblacional")
        self._finalizar(fig, "comparativa_modelos.png")

    def graficar_influencia_r(self, curvas: dict) -> None:
        fig, ax = plt.subplots(figsize=(9, 5.5))
        colores = plt.cm.viridis([0.05, 0.4, 0.7, 0.95])
        for color, (etiqueta, res) in zip(colores, curvas.items()):
            ax.plot(res.tiempo, res.poblacion, color=color, linewidth=2,
                    label=etiqueta)
        self._decorar(ax, "Influencia de la tasa r (modelo determinístico)")
        self._finalizar(fig, "influencia_r.png")

    def graficar_ruido(self, referencia, curvas: dict) -> None:
        fig, ax = plt.subplots(figsize=(9, 5.5))
        ax.plot(referencia.tiempo, referencia.poblacion, "k-", linewidth=2.5,
                label="Determinístico")
        colores = plt.cm.plasma([0.1, 0.4, 0.65, 0.85])
        for color, (etiqueta, res) in zip(colores, curvas.items()):
            ax.plot(res.tiempo, res.poblacion, color=color, linewidth=1.8,
                    label=etiqueta)
        self._decorar(ax, "Efecto del nivel de ruido σ (modelo estocástico)")
        self._finalizar(fig, "efecto_ruido.png")
