package modelo;

import java.io.Serializable;

/**
 * Created by gargui3 on 8/10/16.
 */
public class Condicion implements Serializable {

    private String estado;
    private boolean ruedasGiran;
    private boolean sinRuedas;
    private boolean sinLlaves;
    private boolean fallaMotor;

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public boolean isRuedasGiran() {
        return ruedasGiran;
    }

    public void setRuedasGiran(boolean ruedasGiran) {
        this.ruedasGiran = ruedasGiran;
    }

    public boolean isSinRuedas() {
        return sinRuedas;
    }

    public void setSinRuedas(boolean sinRuedas) {
        this.sinRuedas = sinRuedas;
    }

    public boolean isFallaMotor() {
        return fallaMotor;
    }

    public void setFallaMotor(boolean fallaMotor) {
        this.fallaMotor = fallaMotor;
    }

    public boolean isSinLlaves() {
        return sinLlaves;
    }

    public void setSinLlaves(boolean sinLlaves) {
        this.sinLlaves = sinLlaves;
    }
}
