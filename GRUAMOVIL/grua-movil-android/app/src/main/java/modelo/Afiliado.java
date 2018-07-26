package modelo;

/**
 * Created by gargui3 on 1/01/16.
 */
public class Afiliado {

    private String nombre;
    private String locales;
    private String tipo;
    private String numeroTelefonico;
    private String direccion;

    public Afiliado(String n, String l, String t, String nT, String d) {

        nombre = n;
        locales = l;
        tipo = t;
        numeroTelefonico = nT;
        direccion = d;

    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getLocales() {
        return locales;
    }

    public void setLocales(String locales) {
        this.locales = locales;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getNumeroTelefonico() {
        return numeroTelefonico;
    }

    public void setNumeroTelefonico(String numeroTelefonico) {
        this.numeroTelefonico = numeroTelefonico;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

}
