package com.reedom.audiflow_app

import android.content.Context
import com.google.android.gms.auth.blockstore.Blockstore
import com.google.android.gms.auth.blockstore.DeleteBytesRequest
import com.google.android.gms.auth.blockstore.RetrieveBytesRequest
import com.google.android.gms.auth.blockstore.StoreBytesData
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `audiflow/block_store`: keeps small sync values in Google Play
 * services Block Store, which carries them to a new phone during setup and
 * through a reinstall (docs/architecture/user-data-sync.md, key storage).
 *
 * Values are UTF-8 strings under string keys. Writes ask for cloud backup;
 * Block Store honors it only when the user has backup on and a screen lock.
 */
object BlockStoreChannel {
    private const val CHANNEL_NAME = "audiflow/block_store"

    fun register(messenger: BinaryMessenger, context: Context) {
        val client = Blockstore.getClient(context.applicationContext)
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "write" -> {
                    val key = call.argument<String>("key")
                    val value = call.argument<String>("value")
                    if (key == null || value == null) {
                        result.error("INVALID_ARGUMENT", "key and value are required", null)
                        return@setMethodCallHandler
                    }
                    val data = StoreBytesData.Builder()
                        .setKey(key)
                        .setBytes(value.toByteArray(Charsets.UTF_8))
                        .setShouldBackupToCloud(true)
                        .build()
                    client.storeBytes(data)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("WRITE_FAILED", e.message, null) }
                }
                "readAll" -> {
                    val request = RetrieveBytesRequest.Builder().setRetrieveAll(true).build()
                    client.retrieveBytes(request)
                        .addOnSuccessListener { response ->
                            val values = response.blockstoreDataMap.mapValues { (_, data) ->
                                data.bytes.toString(Charsets.UTF_8)
                            }
                            result.success(values)
                        }
                        .addOnFailureListener { e -> result.error("READ_FAILED", e.message, null) }
                }
                "delete" -> {
                    val key = call.argument<String>("key")
                    if (key == null) {
                        result.error("INVALID_ARGUMENT", "key is required", null)
                        return@setMethodCallHandler
                    }
                    val request = DeleteBytesRequest.Builder().setKeys(listOf(key)).build()
                    client.deleteBytes(request)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("DELETE_FAILED", e.message, null) }
                }
                else -> result.notImplemented()
            }
        }
    }
}
