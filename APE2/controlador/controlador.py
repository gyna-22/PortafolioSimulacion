from dataclasses import replace
from modelo.modelos import (Parametros, ModeloDeterministico, ModeloDiscreto,
                            ModeloEstocastico, ModeloContinuoEuler, estimar_r)

DATOS_BASE = [1000, 1100, 1250, 1400, 1600, 1850, 2100]


class ControladorSimulacion:
    def __init__(self, vista_grafica, datos=None):
        self.grafica = vista_grafica
        self.datos = list(datos or DATOS_BASE)
        self.params = Parametros(p0=self.datos[0], r=estimar_r(self.datos),
                                 sigma=50.0, dt=0.1,
                                 tiempo=len(self.datos) - 1, semilla=42)

    def comparar_modelos(self) -> None:
        p = self.params
        resultados = [ModeloDeterministico().ejecutar(p),
                      ModeloDiscreto().ejecutar(p),
                      ModeloEstocastico().ejecutar(p),
                      ModeloContinuoEuler().ejecutar(p)]
        self.grafica.graficar_comparativa(resultados, self.datos)

    def influencia_r(self) -> None:
        r0 = self.params.r
        curvas = {}
        for factor in (0.5, 1.0, 1.5, -0.5):   # incluye decrecimiento
            p = replace(self.params, r=r0 * factor)
            etiqueta = f"r = {p.r:.3f}" + (" (r estimada)" if factor == 1.0 else "")
            curvas[etiqueta] = ModeloDeterministico().ejecutar(p)
        self.grafica.graficar_influencia_r(curvas)

    def efecto_ruido(self) -> None:
        referencia = ModeloDeterministico().ejecutar(self.params)
        curvas = {}
        for sigma in (0, 25, 100, 250):
            p = replace(self.params, sigma=sigma)
            etiqueta = f"Estocástico σ = {sigma:g}" + (" (sin ruido)" if sigma == 0 else "")
            curvas[etiqueta] = ModeloEstocastico().ejecutar(p)
        self.grafica.graficar_ruido(referencia, curvas)

    def ejecutar(self) -> None:
        self.comparar_modelos()
        self.influencia_r()
        self.efecto_ruido()
