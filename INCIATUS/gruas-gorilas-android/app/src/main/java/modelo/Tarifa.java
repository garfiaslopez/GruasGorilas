package modelo;

/**
 * Created by gargui3 on 10/04/16.
 */
public class Tarifa {

    private String ruta;
    private String precio;

    public Tarifa(String r, String p){
        this.ruta = r;
        this.precio = p;
    }

    public String getRuta() {
        return ruta;
    }

    public void setRuta(String ruta) {
        this.ruta = ruta;
    }

    public String getPrecio() {
        return precio;
    }

    public void setPrecio(String precio) {
        this.precio = precio;
    }
}
