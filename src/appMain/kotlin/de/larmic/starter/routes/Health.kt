package de.larmic.starter.routes

import io.ktor.http.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.healthRoutes() {
    get("/health") {
        call.respond(HttpStatusCode.OK, mapOf("status" to "UP"))
    }

    get("/health/ready") {
        call.respond(HttpStatusCode.OK, mapOf("status" to "READY"))

        // Example for a database check
        // if (isDatabaseConnected) {
        //     call.respond(HttpStatusCode.OK, mapOf(
        //         "status" to "READY",
        //         "checks" to mapOf(
        //             "database" to "UP"
        //         )
        //     ))
        // } else {
        //     call.respond(HttpStatusCode.ServiceUnavailable, mapOf(
        //         "status" to "NOT_READY",
        //         "checks" to mapOf(
        //             "database" to "DOWN"
        //         )
        //     ))
        // }
    }

    get("/health/live") {
        call.respond(HttpStatusCode.OK, mapOf("status" to "UP"))
    }
}