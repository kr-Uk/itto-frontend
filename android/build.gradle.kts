allprojects {
    repositories {
        google()
        mavenCentral()
        // flutter_background_geolocation 로컬 tslocationmanager AAR
        maven {
            val bgGeo = rootProject.findProject(":flutter_background_geolocation")
            url = if (bgGeo != null) {
                uri("${bgGeo.projectDir}/libs")
            } else {
                uri("${rootProject.projectDir}/libs")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
