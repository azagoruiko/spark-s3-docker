job "spark-master-job" {
  datacenters = ["home"]
  type        = "service"
  constraint {
    attribute = "${node.class}"
    value     = "guestworker"
  }
  group "spark-master-group" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "ui" {
        static = 8080
      }
      port "master" {
        static = 7077
      }
    }

    task "spark-master-task" {
      driver = "docker"

      env {
        SPARK_NO_DAEMONIZE = "true"
      }

      config {
        privileged = true
        image = "127.0.0.1:9999/docker/spark-s3:0.0.1"
        command = "bash"
        args = [
          "/opt/spark/sbin/start-master.sh",
        ]

        ports = ["ui", "master"]
      }

      resources {
        cpu    = 1000
        memory = 1000
      }

      service {
        name = "spark-master"
        port = "ui"
        tags = ["urlprefix-/v2"]

        check {
          type     = "http"
          path     = "/v2/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
