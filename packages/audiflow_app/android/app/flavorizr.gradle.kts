import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.reedom.audiflowapp.dev"
            resValue(type = "string", name = "app_name", value = "audiflow dev")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.reedom.audiflowapp.stg"
            resValue(type = "string", name = "app_name", value = "audiflow stg")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.reedom.audiflowapp"
            resValue(type = "string", name = "app_name", value = "audiflow")
        }
    }
}
