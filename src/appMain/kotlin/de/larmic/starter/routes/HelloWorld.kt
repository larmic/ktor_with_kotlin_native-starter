package de.larmic.starter.routes

import io.ktor.http.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.helloWorld() {
    get("/") {
        call.respondText("Hello World from Kotlin/Native!")
    }
}