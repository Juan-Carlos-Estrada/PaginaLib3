package org.pltres.util;

public class Validacion extends Exception {
    
    public Validacion(String mensaje) {
        super (mensaje);
    }
    public static void validarNoVacio(String valor, String nombreCampo)
            throws Validacion {
        if (valor == null || valor.trim().isEmpty()) {
            throw new Validacion(
                    "El campo " + nombreCampo + "no puede estar vacio");
        }
    }

    public static void validarCoincidencia(String a, String b, String mensaje)
            throws Validacion {
        if (!a.equals(b)) {
            throw new Validacion(mensaje);
        }
    }

    public static void validarLongitudMinima(String valor, int min, String mensaje)
            throws Validacion {
        if (valor.length() < min) {
            throw new Validacion(mensaje);
        }
    }

    public static void validarNulo(Object obj, String mensaje)
            throws Validacion {
        if (obj == null) {
            throw new Validacion(mensaje);
        }

    }
}
