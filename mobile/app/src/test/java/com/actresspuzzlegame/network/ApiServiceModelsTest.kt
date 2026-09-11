package com.actresspuzzlegame.network

import com.google.gson.Gson
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ApiServiceModelsTest {
    private val gson = Gson()

    @Test
    fun actressDataAcceptsNumericActiveFlagsFromProduction() {
        val active = gson.fromJson(
            """{"id":1,"name":"Model","thumbnail_image":null,"is_active":1}""",
            ActressData::class.java
        )
        val inactive = gson.fromJson(
            """{"id":2,"name":"Model","thumbnail_image":null,"is_active":0}""",
            ActressData::class.java
        )

        assertTrue(active.isActive)
        assertFalse(inactive.isActive)
    }

    @Test
    fun actressDataStillAcceptsBooleanActiveFlags() {
        val active = gson.fromJson(
            """{"id":1,"name":"Model","thumbnail_image":null,"is_active":true}""",
            ActressData::class.java
        )

        assertTrue(active.isActive)
    }
}
