from modelo import ModeloLluvia, DATOS


class Controlador:
    def __init__(self):
        # Modelo original y modelo ajustado
        self.original = ModeloLluvia(0.5, 0.3, 0.2, "Modelo original: I = 0.5H + 0.3N + 0.2Tf")
        self.ajustado = ModeloLluvia(0.4, 0.4, 0.2, "Modelo ajustado: I = 0.4H + 0.4N + 0.2Tf")

    def calcular_tabla(self, modelo):
        # Calculo de las filas con el modelo
        filas = []
        for hora, humedad, nubosidad, temp in DATOS:
            H, N, Tf, I = modelo.calcular(humedad, nubosidad, temp)
            filas.append({
                "hora": hora, "humedad": humedad, "nubosidad": nubosidad, "temp": temp,
                "H": H, "N": N, "Tf": Tf, "I": I, "estado": modelo.estado(I),
            })
        return filas
