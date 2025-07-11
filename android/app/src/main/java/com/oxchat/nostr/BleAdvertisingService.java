package com.oxchat.nostr;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.os.ParcelUuid;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.UUID;

public class BleAdvertisingService extends Service {
    private static final String TAG = "BleAdvertisingService";
    private static final int NOTIFICATION_ID = 1001;
    private static final String CHANNEL_ID = "ble_advertising_channel";
    private static final UUID SERVICE_UUID = UUID.fromString("F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5C");

    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeAdvertiser bluetoothLeAdvertiser;
    private boolean isAdvertising = false;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "onCreate");
        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        startForeground(NOTIFICATION_ID, createNotification());
        startBleAdvertising();
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        stopBleAdvertising();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "BLE Advertising",
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Keeps BLE advertising active for Bitchat");
            channel.setShowBadge(false);
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private Notification createNotification() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("0xChat Bitchat")
                .setContentText("BLE advertising active")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build();
    }

    private void startBleAdvertising() {
        Log.d(TAG, "Starting BLE advertising...");
        
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            Log.e(TAG, "Bluetooth not available or disabled");
            Log.d(TAG, "Bluetooth adapter: " + (bluetoothAdapter != null ? "available" : "null"));
            Log.d(TAG, "Bluetooth enabled: " + (bluetoothAdapter != null ? bluetoothAdapter.isEnabled() : "N/A"));
            return;
        }
        
        bluetoothLeAdvertiser = bluetoothAdapter.getBluetoothLeAdvertiser();
        if (bluetoothLeAdvertiser == null) {
            Log.e(TAG, "BLE advertising not supported");
            return;
        }
        
        try {
            // Use the peer ID from Dart (8-character hex string)
            // This should match the peer ID generated in _generateSwiftCompatiblePeerId()
            String peerId = "ca5c3d64"; // This should be passed from Dart
            
            Log.d(TAG, "Using peer ID from Dart: " + peerId);
            
            // Set the device name for advertising
            bluetoothAdapter.setName(peerId);
            
            AdvertiseSettings settings = new AdvertiseSettings.Builder()
                    .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                    .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
                    .setConnectable(true)
                    .build();
            
            Log.d(TAG, "Advertise settings: mode=LOW_LATENCY, power=HIGH, connectable=true");
            
            // Primary advertise data - include service UUID and device name
            AdvertiseData data = new AdvertiseData.Builder()
                    .setIncludeTxPowerLevel(true)
                    .addServiceUuid(new ParcelUuid(SERVICE_UUID))
                    .setIncludeDeviceName(true)  // Include device name in primary data
                    .build();
            
            Log.d(TAG, "Advertise data: service UUID=" + SERVICE_UUID + ", include device name=true");
            
            // No scan response needed since device name is in primary data
            bluetoothLeAdvertiser.startAdvertising(settings, data, null, advertiseCallback);
            Log.d(TAG, "Started BLE advertising with peer ID: " + peerId);
            
            // Log the current device name for debugging
            String currentName = bluetoothAdapter.getName();
            Log.d(TAG, "Current device name: " + currentName);
            
        } catch (Exception e) {
            Log.e(TAG, "Failed to start BLE advertising: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void stopBleAdvertising() {
        if (bluetoothLeAdvertiser != null && isAdvertising) {
            bluetoothLeAdvertiser.stopAdvertising(advertiseCallback);
            isAdvertising = false;
            Log.d(TAG, "Stopped BLE advertising");
        }
    }

    private final AdvertiseCallback advertiseCallback = new AdvertiseCallback() {
        @Override
        public void onStartSuccess(AdvertiseSettings settingsInEffect) {
            super.onStartSuccess(settingsInEffect);
            isAdvertising = true;
            Log.d(TAG, "BLE advertising started successfully");
        }

        @Override
        public void onStartFailure(int errorCode) {
            super.onStartFailure(errorCode);
            isAdvertising = false;
            Log.e(TAG, "BLE advertising failed with error code: " + errorCode);
        }
    };
} 