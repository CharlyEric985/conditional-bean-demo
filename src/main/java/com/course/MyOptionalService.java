package com.course;

import jakarta.enterprise.context.ApplicationScoped;
import io.quarkus.arc.properties.IfBuildProperty;


@ApplicationScoped
@IfBuildProperty(name = "feature.notifications.enabled",stringValue = "true")
public class MyOptionalService {
    public String message(){
        return "Activé";
    }
}