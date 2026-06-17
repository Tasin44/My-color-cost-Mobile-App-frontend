# Jackson rules for R8 / ProGuard
-dontwarn com.fasterxml.jackson.**
-keep class com.fasterxml.jackson.** { *; }

# Also helpful for OpenTelemetry if needed
-dontwarn io.opentelemetry.**
-keep class io.opentelemetry.** { *; }
