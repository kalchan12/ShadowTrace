package com.shadowtrace.service.storage

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "shadowtrace_service_prefs")

class ServicePreferences(private val context: Context) {
    companion object {
        val KEY_LAST_ACTIVE_GROUP = stringPreferencesKey("last_active_group_id")
        val KEY_AUTO_START_ON_BOOT = booleanPreferencesKey("auto_start_on_boot")
    }

    val lastActiveGroupId: Flow<String?> = context.dataStore.data.map { prefs ->
        prefs[KEY_LAST_ACTIVE_GROUP]
    }

    suspend fun setLastActiveGroupId(groupId: String?) {
        context.dataStore.edit { prefs ->
            if (groupId != null) {
                prefs[KEY_LAST_ACTIVE_GROUP] = groupId
            } else {
                prefs.remove(KEY_LAST_ACTIVE_GROUP)
            }
        }
    }
}
