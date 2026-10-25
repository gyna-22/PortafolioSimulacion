from dataclasses import dataclass
import math
import numpy as np


@dataclass
class Parametros:
    p0: float            # población inicial
    r: float             # tasa de crecimiento
    sigma: float         # nivel de aleatoriedad (modelo estocástico)
    dt: float            # tamaño del paso (modelo continuo / Euler)
    tiempo: int          # tiempo total (períodos)
    semilla: int | None = None


@dataclass
class Resultado:
    nombre: str
    tiempo: np.ndarray
    poblacion: np.ndarray


class ModeloDeterministico:
    #P(t) = P0 * e^(r t). Sin aleatoriedad
    nombre = "Determinístico"

    def ejecutar(self, p: Parametros) -> Resultado:
        t = np.arange(0, p.tiempo + 1, dtype=float)
        poblacion = p.p0 * np.exp(p.r * t)
        return Resultado(self.nombre, t, poblacion)


class ModeloDiscreto:
    #P(t+1) = P(t) + r P(t), en intervalos de tiempo definidos
    nombre = "Discreto"

    def ejecutar(self, p: Parametros) -> Resultado:
        poblacion = [p.p0]
        for _ in range(1, p.tiempo + 1):
            actual = poblacion[-1]
            poblacion.append(actual + p.r * actual)
        return Resultado(self.nombre, np.arange(p.tiempo + 1, dtype=float),
                         np.array(poblacion))


class ModeloEstocastico:
    #P(t+1) = P(t) + r P(t) + eps,  eps ~ N(0, sigma^2)
    nombre = "Estocástico"

    def ejecutar(self, p: Parametros) -> Resultado:
        rng = np.random.default_rng(p.semilla)
        poblacion = [p.p0]
        for _ in range(1, p.tiempo + 1):
            ruido = rng.normal(0.0, p.sigma)
            actual = poblacion[-1]
            nueva = actual + p.r * actual + ruido
            poblacion.append(max(nueva, 0.0))
        return Resultado(self.nombre, np.arange(p.tiempo + 1, dtype=float),
                         np.array(poblacion))


class ModeloContinuoEuler:
    #dP/dt = rP aproximado con Euler: P(t+dt) = P(t) + dt * r P(t)
    nombre = "Continuo (Euler)"

    def ejecutar(self, p: Parametros) -> Resultado:
        pasos = int(round(p.tiempo / p.dt))
        t = np.arange(pasos + 1) * p.dt
        poblacion = [p.p0]
        for _ in range(pasos):
            actual = poblacion[-1]
            cambio = p.r * actual
            poblacion.append(actual + p.dt * cambio)
        return Resultado(self.nombre, t, np.array(poblacion))


def estimar_r(datos: list[float]) -> float:
    #Estima r (continua) a partir del arreglo de datos: r = ln(Pn/P0)/n
    n = len(datos) - 1
    return math.log(datos[-1] / datos[0]) / n


def rmse_contra_datos(resultado: Resultado, datos: list[float]) -> float:
    #Error cuadrático medio entre el modelo y los datos observados
    sim = np.interp(np.arange(len(datos)), resultado.tiempo, resultado.poblacion)
    return float(np.sqrt(np.mean((sim - np.array(datos)) ** 2)))
