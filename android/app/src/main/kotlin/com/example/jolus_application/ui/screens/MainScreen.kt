package com.example.jolus_application.ui.screens

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.jolus_application.ui.navigation.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(startScreen: Screen) {
    var currentScreen by remember { mutableStateOf(startScreen) }

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
                tonalElevation = 8.dp
            ) {
                val items = listOf(
                    NavigationItem("Inicio", Icons.Default.Home, Screen.Home),
                    NavigationItem("Servicios", Icons.Default.Apps, Screen.Services),
                    NavigationItem("Carrito", Icons.Default.ShoppingCart, Screen.Cart),
                    NavigationItem("Historial", Icons.Default.History, Screen.History),
                    NavigationItem("Perfil", Icons.Default.Person, Screen.Profile)
                )

                items.forEach { item ->
                    NavigationBarItem(
                        icon = { Icon(item.icon, contentDescription = item.label, modifier = Modifier.size(24.dp)) },
                        label = { Text(item.label, fontSize = 11.sp) },
                        selected = currentScreen == item.screen,
                        onClick = { currentScreen = item.screen },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = MaterialTheme.colorScheme.primary,
                            selectedTextColor = MaterialTheme.colorScheme.primary,
                            unselectedIconColor = MaterialTheme.colorScheme.secondary,
                            unselectedTextColor = MaterialTheme.colorScheme.secondary,
                            indicatorColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.1f)
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            when (currentScreen) {
                is Screen.Home -> HomeScreen()
                is Screen.Services -> PlaceholderScreen("Servicios")
                is Screen.Cart -> PlaceholderScreen("Carrito")
                is Screen.History -> PlaceholderScreen("Historial")
                is Screen.Profile -> PlaceholderScreen("Perfil")
                else -> HomeScreen()
            }
        }
    }
}

data class NavigationItem(val label: String, val icon: ImageVector, val screen: Screen)

@Composable
fun PlaceholderScreen(name: String) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = "Pantalla de $name", style = MaterialTheme.typography.headlineMedium)
    }
}
