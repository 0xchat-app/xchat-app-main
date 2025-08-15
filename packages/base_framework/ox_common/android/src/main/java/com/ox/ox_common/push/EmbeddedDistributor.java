package com.ox.ox_common.push;

import android.content.Context;

import org.unifiedpush.android.foss_embedded_fcm_distributor.EmbeddedDistributorReceiver;

/**
 * Embedded FCM Distributor for handling FCM push notifications
 * This class extends the UnifiedPush embedded FCM distributor
 */
public class EmbeddedDistributor extends EmbeddedDistributorReceiver {
    
    @Override
    public String getGoogleProjectNumber() {
        return "426689947325";
    }

    @Override
    public String getEndpoint(Context context, String token, String instance) {
        return "Embedded-FCM/FCM?v2&instance=" + instance + "&token=" + token;
    }
}
