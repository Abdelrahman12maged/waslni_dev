package com.abdo.carapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class TripWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.trip_widget)

            // Read saved data from Flutter
            val isLoggedIn    = widgetData.getBoolean("widget_is_logged_in", false)
            val userType      = widgetData.getString("widget_user_type", "") ?: ""
            val userName      = widgetData.getString("widget_user_name", "") ?: ""
            val infoText      = widgetData.getString("widget_info_text", "") ?: ""
            val hasActiveTrip = widgetData.getBoolean("widget_has_active_trip", false)
            val activeTripUri = widgetData.getString("widget_active_trip_uri", "") ?: ""
            val defaultBtnPrimary = context.getString(R.string.open_app)
            val btnPrimary    = widgetData.getString("widget_btn_primary_label", defaultBtnPrimary) ?: defaultBtnPrimary
            val btnSecondary  = widgetData.getString("widget_btn_secondary_label", "") ?: ""
            val showSecondary = widgetData.getBoolean("widget_show_secondary_btn", false)

            // ── Icon & Name ──────────────────────────────────────────
            val icon = when {
                hasActiveTrip          -> "🚕"
                userType == "driver"    -> "🚗"
                userType == "passenger" -> "👤"
                else                   -> "🚕"
            }
            views.setTextViewText(R.id.widget_icon, icon)

            val displayName = if (isLoggedIn && userName.isNotEmpty()) userName else context.getString(R.string.app_name)
            views.setTextViewText(R.id.widget_user_name, displayName)

            // ── Badge (Active trip / Driver / Passenger) ─────────────
            val badge = when {
                hasActiveTrip           -> "⚡ تتبع مباشر"
                userType == "driver"    -> "سائق"
                userType == "passenger" -> "راكب"
                else                    -> ""
            }
            if (badge.isNotEmpty()) {
                views.setTextViewText(R.id.widget_user_type_badge, badge)
                if (hasActiveTrip) {
                    views.setInt(R.id.widget_user_type_badge, "setBackgroundResource", R.drawable.badge_active_background)
                    views.setTextColor(R.id.widget_user_type_badge, android.graphics.Color.parseColor("#34D399"))
                } else {
                    views.setInt(R.id.widget_user_type_badge, "setBackgroundResource", R.drawable.badge_background)
                    views.setTextColor(R.id.widget_user_type_badge, android.graphics.Color.parseColor("#38BDF8"))
                }
                views.setViewVisibility(R.id.widget_user_type_badge, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_user_type_badge, View.GONE)
            }

            // ── Info Text ────────────────────────────────────────────
            val info = if (infoText.isNotEmpty()) infoText else "اضغط لفتح التطبيق"
            views.setTextViewText(R.id.widget_info_text, info)

            // ── Primary Button ───────────────────────────────────────
            views.setTextViewText(R.id.widget_btn_primary, btnPrimary)
            val primaryUri = when {
                hasActiveTrip && activeTripUri.isNotEmpty() -> activeTripUri
                userType == "driver"    -> "carapp://app/driver/trips/available"
                userType == "passenger" -> "carapp://app/passenger/trips/add-private"
                else                    -> "carapp://app/open"
            }
            val primaryPendingIntent = buildLaunchIntent(context, primaryUri)
            views.setOnClickPendingIntent(R.id.widget_btn_primary, primaryPendingIntent)

            // ── Secondary Button ─────────────────────────────────────
            if (!hasActiveTrip && showSecondary && btnSecondary.isNotEmpty()) {
                views.setTextViewText(R.id.widget_btn_secondary, btnSecondary)
                views.setViewVisibility(R.id.widget_btn_secondary, View.VISIBLE)
                val secondaryUri = "carapp://app/passenger/trips/add-shared"
                val secondaryPendingIntent = buildLaunchIntent(context, secondaryUri)
                views.setOnClickPendingIntent(R.id.widget_btn_secondary, secondaryPendingIntent)
            } else {
                views.setViewVisibility(R.id.widget_btn_secondary, View.GONE)
            }

            // ── Whole widget tap → open app ──────────────────────────
            val openIntent = buildLaunchIntent(context, "carapp://app/open")
            views.setOnClickPendingIntent(R.id.widget_icon, openIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback view in case of any runtime error
            val fallbackViews = RemoteViews(context.packageName, R.layout.trip_widget)
            fallbackViews.setTextViewText(R.id.widget_user_name, context.getString(R.string.app_name))
            fallbackViews.setTextViewText(R.id.widget_info_text, "اضغط لفتح التطبيق")
            fallbackViews.setTextViewText(R.id.widget_btn_primary, context.getString(R.string.open_app))
            fallbackViews.setViewVisibility(R.id.widget_user_type_badge, View.GONE)
            fallbackViews.setViewVisibility(R.id.widget_btn_secondary, View.GONE)
            val openIntent = buildLaunchIntent(context, "carapp://app/open")
            fallbackViews.setOnClickPendingIntent(R.id.widget_btn_primary, openIntent)
            appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
        }
    }

    private fun buildLaunchIntent(context: Context, uriString: String): PendingIntent {
        return es.antonborri.home_widget.HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            android.net.Uri.parse(uriString)
        )
    }
}

