package Elements;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.widget.DatePicker;

import com.example.gargui3.gruasgorilas.SeleccionPedido;

import java.util.Calendar;

import modelo.Fecha;

/**
 * Created by alejandro on 4/03/17.
 */

public class DatePickerFragment extends DialogFragment
        implements DatePickerDialog.OnDateSetListener {

    private SeleccionPedido s;

    public void setS(SeleccionPedido s) {
        this.s = s;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        // Use the current date as the default date in the picker
        final Calendar c = Calendar.getInstance();
        int year = c.get(Calendar.YEAR);
        int month = c.get(Calendar.MONTH);
        int day = c.get(Calendar.DAY_OF_MONTH);

        DatePickerDialog pickerDate = new DatePickerDialog(getActivity(), this, year, month, day);

        // Create a new instance of DatePickerDialog and return it
        return pickerDate;
    }

    @Override
    public void onDateSet(DatePicker view, int year, int month, int dayOfMonth) {
        Fecha f = new Fecha(dayOfMonth, month+1, year);
        s.setFechaCotizacion(f);
        s.setTime();
    }
}
