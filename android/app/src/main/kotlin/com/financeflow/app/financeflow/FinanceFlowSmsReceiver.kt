package com.financeflow.app.financeflow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import org.json.JSONObject

class FinanceFlowSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        if (!IngestionEventStore.isSmsEnabled(context)) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isEmpty()) return
        val sender = messages.firstOrNull()?.displayOriginatingAddress.orEmpty()
        val body = messages.joinToString(separator = "") { it.displayMessageBody.orEmpty() }
        val selected = IngestionEventStore.selectedSmsSenders(context)
        val canonicalSender = sender.uppercase().replace(Regex("[^A-Z0-9]"), "")
        if (selected.isNotEmpty() && selected.none { canonicalSender.contains(it.uppercase()) }) return
        if (!IngestionEventStore.isFinancialCandidate(body)) return

        val timestamp = messages.minOfOrNull { it.timestampMillis } ?: System.currentTimeMillis()
        val id = IngestionEventStore.eventId("sms", sender, body, timestamp.toString())
        IngestionEventStore.enqueue(context, JSONObject().apply {
            put("eventId", id)
            put("type", "sms")
            put("sender", sender)
            put("body", body)
            put("timestamp", timestamp)
            put("sourcePackage", "android.telephony")
        })
        MainActivity.notifyEventsAvailable()
    }
}
