from controlador.controlador import ControladorSimulacion
from vista.vista_grafica import VistaGrafica


def main() -> None:
    grafica = VistaGrafica(carpeta_salida="resultados", mostrar=True)
    ControladorSimulacion(grafica).ejecutar()


if __name__ == "__main__":
    main()
