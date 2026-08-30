package com.financeflow.app.financeflow

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class FinancialEventGateTest {
    @Test
    fun `accepts real bank UPI and card candidate wording`() {
        val messages = listOf(
            "HDFC Bank: Rs 1,500.00 debited from A/c XX4321 to SWIGGY. UPI Ref 42352345.",
            "ICICI Bank: transaction successful. Payment of INR 450 made using card ending 1234.",
            "SBI UPI transfer of Rs.250 completed from your account.",
            "Axis card ending 9876 used for ₹650 at STARBUCKS.",
            "UPI mandate executed. Amount: 799 from account XX1001.",
        )

        messages.forEach { assertTrue(FinancialEventGate.isFinancialCandidate(it)) }
    }

    @Test
    fun `rejects OTP promotion and ordinary text`() {
        val messages = listOf(
            "123456 is your OTP to sign in. Do not share it.",
            "Pre-approved offer: get Rs 10,000 cashback. Apply now.",
            "Your verification code is 123456.",
            "Dinner at 8?",
        )

        messages.forEach { assertFalse(FinancialEventGate.isFinancialCandidate(it)) }
    }

    @Test
    fun `normalizes operator sender headers and keeps explicit allow lists`() {
        assertTrue(FinancialEventGate.senderMatches(setOf("HDFCBK"), "VM-HDFCBK-S"))
        assertTrue(FinancialEventGate.senderMatches(emptySet(), "VK-NEWBANK"))
        assertFalse(FinancialEventGate.senderMatches(setOf("HDFCBK"), "VK-ICICIB"))
    }
}
