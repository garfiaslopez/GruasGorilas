package modelo;

import java.io.Serializable;

/**
 * Created by gargui3 on 21/11/16.
 */
public class Sucursal implements Serializable{

    private String id;
    private String  taller_id;
    private String country;
    private String phone;
    private String address;
    private Double lng;
    private Double lat;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTaller_id() {
        return taller_id;
    }

    public void setTaller_id(String taller_id) {
        this.taller_id = taller_id;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Double getLng() {
        return lng;
    }

    public void setLng(Double lng) {
        this.lng = lng;
    }

    public Double getLat() {
        return lat;
    }

    public void setLat(Double lat) {
        this.lat = lat;
    }
}
