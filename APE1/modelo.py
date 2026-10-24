# Datos
DATOS = [
    ("06:00", 65, 40, 14),
    ("08:00", 70, 50, 16),
    ("10:00", 68, 45, 18),
    ("12:00", 60, 30, 22),
    ("14:00", 75, 70, 20),
    ("16:00", 85, 85, 18),
    ("18:00", 92, 95, 16),
    ("20:00", 88, 90, 17),
    ("22:00", 80, 75, 15),
]


class ModeloLluvia:
    def __init__(self, a, b, c, nombre):
        # a, b, c son los pesos de: H + N + Tf
        self.a = a
        self.b = b
        self.c = c
        self.nombre = nombre

    def factor_temperatura(self, temp):
        # Entre 10 y 28 baja 0.05 por cada grado (12->0.90, 14->0.80, ...)
        if temp <= 10:
            return 1.0
        if temp >= 28:
            return 0.1
        return 1.0 - 0.05 * (temp - 10)

    def estado(self, indice):
        if indice < 0.40:
            return "Sin lluvia"
        elif indice < 0.60:
            return "Baja posibilidad"
        elif indice < 0.75:
            return "Lluvia probable"
        else:
            return "Lluvia"

    def calcular(self, humedad, nubosidad, temp):
        H = humedad / 100       # normalizar: 65 % -> 0.65
        N = nubosidad / 100
        Tf = self.factor_temperatura(temp)
        I = self.a * H + self.b * N + self.c * Tf
        return H, N, Tf, I
