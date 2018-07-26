package modelo;

import java.io.Serializable;

/**
 * Created by alejandro on 7/03/17.
 */

public class Agenda implements Serializable {

    private String numPedido;
    private String fechaPedido;
    private String origenPedido;
    private String destinoPedido;
    private String gruyero;
    private String precioPedido;
    private String nombreCliente;
    private String nombreOperador;

    public String getNumPedido() {
        return numPedido;
    }

    public void setNumPedido(String numPedido) {
        this.numPedido = numPedido;
    }

    public String getFechaPedido() {
        return fechaPedido;
    }

    public void setFechaPedido(String fechaPedido) {
        this.fechaPedido = fechaPedido;
    }

    public String getOrigenPedido() {
        return origenPedido;
    }

    public void setOrigenPedido(String origenPedido) {
        this.origenPedido = origenPedido;
    }

    public String getDestinoPedido() {
        return destinoPedido;
    }

    public void setDestinoPedido(String destinoPedido) {
        this.destinoPedido = destinoPedido;
    }

    public String getGruyero() {
        return gruyero;
    }

    public void setGruyero(String gruyero) {
        this.gruyero = gruyero;
    }

    public String getPrecioPedido() {
        return precioPedido;
    }

    public void setPrecioPedido(String precioPedido) {
        this.precioPedido = precioPedido;
    }

    public String getNombreCliente() {
        return nombreCliente;
    }

    public void setNombreCliente(String nombreCliente) {
        this.nombreCliente = nombreCliente;
    }

    public String getNombreOperador() {
        return nombreOperador;
    }

    public void setNombreOperador(String nombreOperador) {
        this.nombreOperador = nombreOperador;
    }
}
