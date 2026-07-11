allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 1. Apply the Namespace fix FIRST
subprojects {
    val namespaceFix = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(android) == null) {
                    setNamespace.invoke(android, "dev.isar.${project.name.replace("-", "_")}")
                }
            } catch (e: Exception) { }
        }
    }

    if (project.state.executed) {
        namespaceFix()
    } else {
        project.afterEvaluate { namespaceFix() }
    }
}

// 2. Then do the evaluation dependencies
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val sdkFix = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkVersion.invoke(android, 35)
            } catch (e: Exception) {
                try {
                    val compileSdkVersion = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    compileSdkVersion.invoke(android, 35)
                } catch (e2: Exception) {}
            }
        }
    }

    if (project.state.executed) {
        sdkFix()
    } else {
        project.afterEvaluate { sdkFix() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
