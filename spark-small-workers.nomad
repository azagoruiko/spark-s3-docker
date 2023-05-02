job "spark-small-workers-job" {
  datacenters = ["home"]
  type        = "service"
  constraint {
    attribute = "${node.class}"
    value     = "guestworker"
  }
  group "spark-small-workers-group" {
    count = 2

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    network {
      port "ui" {
        static = 8081
      }
      port "worker" {
        static = 7077
      }
    }

    task "spark-small-workers-task" {
      driver = "docker"

      env {
        SPARK_NO_DAEMONIZE = "true"
      }
      template {
        data = <<EOH
        {{ range service "spark-master" }}
        SPARK_MASTER={{ .Address }}:{{ .Port }}

        {{ end }}
        EOH
        destination = "local/file.env"
        env         = true
      }
      # template {
      #   data        = "KEY={{ key \"service/my-key\" }}"
      #   destination = "local/file.env"
      #   env         = true
      # }

      config {
        privileged = true
        image = "10.8.0.5:9999/docker/spark-master:0.0.5"
        command = "bash"
        args = [
          "/opt/spark/sbin/start-worker.sh",
          "$SPARK_MASTER"
        ]

        ports = ["ui", "worker"]
      }

      resources {
        memory = 600
      }

      service {
        name = "small-workers"
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
