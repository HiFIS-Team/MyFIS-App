package com.myfis.app.shared

import android.os.Build

class AndroidPlatform : Platform {
    override val name: String = "Android ${Build.VERSION.SDK_INT}"
}

actual fun currentPlatform(): Platform = AndroidPlatform()
