package com.financeflow.app.financeflow

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.security.MessageDigest

/** Private, bounded queue shared by Android receivers and the Flutter bridge. */
object IngestionEventStore {
    private const val PREFS = "financeflow_ingestion"
    private const val QUEUE = "event_queue"
    private const val MAX_EVENTS = 200

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun isSmsEnabled(context: Context): Boolean = prefs(context).getBoolean("sms_enabled", false)
    fun isNotificationEnabled(context: Context): Boolean =
        prefs(context).getBoolean("notification_enabled", false)

    fun selectedSmsSenders(context: Context): Set<String> =
        prefs(context).getStringSet("sms_senders", emptySet()) ?: emptySet()

    fun selectedNotificationPackages(context: Context): Set<String> =
        prefs(context).getStringSet("notification_packages", emptySet()) ?: emptySet()

    fun configure(
        context: Context,
        smsEnabled: Boolean,
        notificationEnabled: Boolean,
        smsSenders: Set<String>,
        notificationPackages: Set<String>,
    ) {
        prefs(context).edit()
            .putBoolean("sms_enabled", smsEnabled)
            .putBoolean("notification_enabled", notificationEnabled)
            .putStringSet("sms_senders", smsSenders)
            .putStringSet("notification_packages", notificationPackages)
            // A receiver can run immediately after the Flutter method returns.
            // Commit makes the configuration visible before that happens.
            .commit()
    }

    @Synchronized
    fun enqueue(context: Context, event: JSONObject) {
        val stored = runCatching { JSONArray(prefs(context).getString(QUEUE, "[]")) }
            .getOrElse { JSONArray() }
        val id = event.optString("eventId")
        for (index in 0 until stored.length()) {
            if (stored.optJSONObject(index)?.optString("eventId") == id) return
        }
        stored.put(event)
        val bounded = JSONArray()
        val start = maxOf(0, stored.length() - MAX_EVENTS)
        for (index in start until stored.length()) bounded.put(stored.get(index))
        // Notify Dart only after the event is durable.  Using apply() here can
        // race a foreground MethodChannel drain and leave an event unnoticed.
        prefs(context).edit().putString(QUEUE, bounded.toString()).commit()
    }

    @Synchronized
    fun pending(context: Context): List<Map<String, Any?>> {
        val stored = runCatching { JSONArray(prefs(context).getString(QUEUE, "[]")) }
            .getOrElse { JSONArray() }
        val result = mutableListOf<Map<String, Any?>>()
        for (index in 0 until stored.length()) {
            val item = stored.optJSONObject(index) ?: continue
            val map = mutableMapOf<String, Any?>()
            item.keys().forEach { key -> map[key] = item.opt(key).takeUnless { it == JSONObject.NULL } }
            result.add(map)
        }
        return result
    }

    @Synchronized
    fun acknowledge(context: Context, ids: Set<String>) {
        if (ids.isEmpty()) return
        val stored = runCatching { JSONArray(prefs(context).getString(QUEUE, "[]")) }
            .getOrElse { JSONArray() }
        val remaining = JSONArray()
        for (index in 0 until stored.length()) {
            val item = stored.optJSONObject(index) ?: continue
            if (item.optString("eventId") !in ids) remaining.put(item)
        }
        prefs(context).edit().putString(QUEUE, remaining.toString()).commit()
    }

    fun eventId(vararg values: String): String {
        val bytes = MessageDigest.getInstance("SHA-256")
            .digest(values.joinToString("|").toByteArray(Charsets.UTF_8))
        return bytes.take(16).joinToString("") { "%02x".format(it) }
    }

    fun isFinancialCandidate(text: String): Boolean =
        FinancialEventGate.isFinancialCandidate(text)
}
