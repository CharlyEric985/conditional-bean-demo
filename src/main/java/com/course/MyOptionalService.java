package com.course;

import io.quarkus.arc.properties.IfBuildProperty;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
@IfBuildProperty(name = "feature.X.enabled", stringValue = "true")
public class MyOptionalService {

    public String getMessage() {
        return "Feature X is active!";
    }
}