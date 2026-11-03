package com.course;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.annotation.PostConstruct;

import io.quarkus.arc.properties.IfBuildProperty;
import io.quarkus.runtime.Startup;

@Startup
@ApplicationScoped
@IfBuildProperty(
    name = "feature.test.enabled",
    stringValue = "true"
)
public class TestService {

    @PostConstruct
    void init() {
        System.out.println("========== TEST SERVICE ACTIVE ==========");
    }
}