name := "App"
version := "1.4.6"
scalaVersion := "2.12.2"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "3.1.0",
  "org.apache.spark" %% "spark-sql" % "3.1.0",
  "org.apache.logging.log4j" % "log4j-core" % "2.14.0",
  "org.apache.spark" %% "spark-hive" % "2.4.7",
  "org.apache.spark" %% "spark-streaming" % "3.1.0",
  "com.typesafe.akka" %% "akka-actor" % "2.5.23",
  "com.github.scopt" %% "scopt" % "3.6.0",
  "joda-time" % "joda-time" % "2.9.9",
  )


