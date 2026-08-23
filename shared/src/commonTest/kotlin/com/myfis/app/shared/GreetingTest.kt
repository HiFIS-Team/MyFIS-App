package com.myfis.app.shared

import kotlin.test.Test
import kotlin.test.assertTrue

class GreetingTest {
    @Test
    fun greetingContainsPlatformName() {
        assertTrue(Greeting().greet().contains(currentPlatform().name))
    }
}
