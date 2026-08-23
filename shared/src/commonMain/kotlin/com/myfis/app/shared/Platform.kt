package com.myfis.app.shared

interface Platform {
    val name: String
}

expect fun currentPlatform(): Platform
