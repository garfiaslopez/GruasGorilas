package modelo;

import org.json.JSONArray;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by gargui3 on 21/11/16.
 */
public class Taller implements Serializable {

    private String id;
    private String name;
    private String description;
    private Boolean activo;
    private String promoDescription;
    private String phone;
    private String firstPhoto;
    private String secondPhoto;
    private String thirdPhoto;
    private String categorie;
    private String color;
    private String logo;
    private ArrayList<Sucursal> sucursales;

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
    }

    public ArrayList<Sucursal> getSucursales() {
        return sucursales;
    }

    public void setSucursales(ArrayList<Sucursal> sucursales) {
        this.sucursales = sucursales;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public String getPromoDescription() {
        return promoDescription;
    }

    public void setPromoDescription(String promoDescription) {
        this.promoDescription = promoDescription;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getFirstPhoto() {
        return firstPhoto;
    }

    public void setFirstPhoto(String firstPhoto) {
        this.firstPhoto = firstPhoto;
    }

    public String getSecondPhoto() {
        return secondPhoto;
    }

    public void setSecondPhoto(String secondPhoto) {
        this.secondPhoto = secondPhoto;
    }

    public String getThirdPhoto() {
        return thirdPhoto;
    }

    public void setThirdPhoto(String thirdPhoto) {
        this.thirdPhoto = thirdPhoto;
    }

    public String getCategorie() {
        return categorie;
    }

    public void setCategorie(String categorie) {
        this.categorie = categorie;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }
}
