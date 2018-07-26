package com.example.gargui3.gruasgorilas;

import android.app.Application;
import android.support.v4.content.ContextCompat;

import com.urbanairship.UAirship;
import com.urbanairship.push.notifications.DefaultNotificationFactory;

/**
 * Created by gargui3 on 2/08/16
 */
public class UrbanNotifications extends Application {

    @Override
    public void onCreate(){
        super.onCreate();

        UAirship.takeOff(this, new UAirship.OnReadyCallback() {

            @Override
            public void onAirshipReady(UAirship uAirship) {
                // Create a customized default notification factory
                DefaultNotificationFactory notificationFactory;
                notificationFactory = new DefaultNotificationFactory(getApplicationContext());

                // Custom notification icon
                notificationFactory.setSmallIconId(R.mipmap.car);

                // The accent color for Android Lollipop+
                notificationFactory.setColor(ContextCompat.getColor(getApplicationContext(), R.color.colorPrimaryYellow));

                // Set the factory on the PushManager
                uAirship.getPushManager().setNotificationFactory(notificationFactory);
                uAirship.getPushManager().setUserNotificationsEnabled(true);
            }

        });
    }

}
