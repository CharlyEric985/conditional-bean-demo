package com.course;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import io.quarkus.arc.properties.IfBuildProperty;
import jakarta.inject.Inject;


@Path("/notifications")
@IfBuildProperty(name = "feature.notifications.enabled",stringValue = "true")
public class NotificationResource {
    @Inject
    MyOptionalService notificationService;
    @GET
    public String getNotificationStatus() {
        return notificationService.message();
    }
    
    
}
