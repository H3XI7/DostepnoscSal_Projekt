package com.example.pw180088

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weather_widget_layout).apply {
                val city = widgetData.getString("widget_city", "WARSZAWA")
                val temp = widgetData.getString("widget_temp", "21°C")
                val condition = widgetData.getString("widget_condition", "Słonecznie")
                val aqi = widgetData.getString("widget_aqi", "AQI: Dobra")

                setTextViewText(R.id.widget_city, city)
                setTextViewText(R.id.widget_temp, temp)
                setTextViewText(R.id.widget_condition, condition)
                setTextViewText(R.id.widget_aqi, aqi)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
