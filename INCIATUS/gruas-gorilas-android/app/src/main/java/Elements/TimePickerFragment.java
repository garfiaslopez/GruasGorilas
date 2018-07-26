package Elements;

import android.app.Dialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.text.format.DateFormat;
import android.widget.TimePicker;

import com.example.gargui3.gruasgorilas.SeleccionPedido;

import java.util.Calendar;

import modelo.Fecha;

/**
 * Created by alejandro on 4/03/17.
 */

public class TimePickerFragment extends DialogFragment
        implements TimePickerDialog.OnTimeSetListener {

    private Fecha f;
    private SeleccionPedido s;

    public void setF(Fecha f) {
        this.f = f;
    }

    public void setS(SeleccionPedido s) {
        this.s = s;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        // Use the current time as the default values for the picker
        final Calendar c = Calendar.getInstance();
        int hour = c.get(Calendar.HOUR_OF_DAY);
        int minute = c.get(Calendar.MINUTE);

        // Create a new instance of TimePickerDialog and return it
        return new TimePickerDialog(getActivity(), this, hour, minute,
                DateFormat.is24HourFormat(getActivity()));
    }

    @Override
    public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
        f.setHour(hourOfDay);
        f.setMinute(minute);
        s.setFechaCotizacion(f);
        s.showDate();
    }
}
