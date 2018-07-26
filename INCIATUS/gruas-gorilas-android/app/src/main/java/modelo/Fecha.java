package modelo;

/**
 * Created by alejandro on 4/03/17.
 */

public class Fecha {

    private int year;
    private int dayofmonth;
    private int month;
    private int hour;
    private int minute;

    public Fecha(){

    }

    public Fecha(int dayofmonth, int month, int year){
        this.dayofmonth = dayofmonth;
        this.month = month;
        this.year = year;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public int getDayofmonth() {
        return dayofmonth;
    }

    public void setDayofmonth(int dayofmonth) {
        this.dayofmonth = dayofmonth;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public int getHour() {
        return hour;
    }

    public void setHour(int hour) {
        this.hour = hour;
    }

    public int getMinute() {
        return minute;
    }

    public void setMinute(int minute) {
        this.minute = minute;
    }
}
