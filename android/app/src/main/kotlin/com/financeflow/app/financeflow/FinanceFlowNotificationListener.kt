package com.financeflow.app.financeflow

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONObject

class FinanceFlowNotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (!IngestionEventStore.isNotificationEnabled(this)) return
        val selected = IngestionEventStore.selectedNotificationPackages(this)
        if (selected.isNotEmpty() && sbn.packageName !in selected) return

        val extras = sbn.notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = sequenceOf(
            extras.getCharSequence(Notification.EXTRA_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString(),
        ).filterNotNull().firstOrNull { it.isNotBlank() }.orEmpty()
        if (!IngestionEventStore.isFinancialCandidate("$title $text")) return

        // key + postTime collapses repeated callbacks for the same notification version.
        val id = IngestionEventStore.eventId("notification", sbn.key, sbn.postTime.toString(), title, text)
        IngestionEventStore.enqueue(this, JSONObject().apply {
            put("eventId", id)
            put("type", "notification")
            put("packageName", sbn.packageName)
            put("title", title)
            put("text", text)
            put("timestamp", sbn.postTime)
            put("notificationKey", sbn.key)
        })
        MainActivity.notifyEventsAvailable()
    }
}
