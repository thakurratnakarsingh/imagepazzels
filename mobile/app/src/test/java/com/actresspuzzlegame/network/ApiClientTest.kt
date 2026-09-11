package com.actresspuzzlegame.network

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ApiClientTest {
    @Test
    fun publicAssetUrlRewritesLocalhostUploadUrlsToConfiguredServer() {
        assertEquals(
            "${ApiClient.BASE_SERVER_URL}uploads/splash/example.webp",
            ApiClient.publicAssetUrl("http://localhost:5000/uploads/splash/example.webp")
        )

        assertEquals(
            "${ApiClient.BASE_SERVER_URL}uploads/actresses/optimized/example.webp",
            ApiClient.publicAssetUrl("http://127.0.0.1:8080/uploads/actresses/optimized/example.webp")
        )
    }

    @Test
    fun publicAssetUrlBuildsUploadUrlsFromRelativePaths() {
        assertEquals(
            "${ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/example.webp",
            ApiClient.publicAssetUrl("actresses/thumbnails/example.webp")
        )

        assertEquals(
            "${ApiClient.BASE_SERVER_URL}uploads/splash/example.webp",
            ApiClient.publicAssetUrl("/uploads/splash/example.webp")
        )
    }

    @Test
    fun publicAssetUrlKeepsPublicUrlsAndIgnoresBlankValues() {
        assertEquals(
            "https://cdn.example.com/uploads/example.webp",
            ApiClient.publicAssetUrl("https://cdn.example.com/uploads/example.webp")
        )

        assertNull(ApiClient.publicAssetUrl(null))
        assertNull(ApiClient.publicAssetUrl(" "))
    }
}
