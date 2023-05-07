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
      template {
        data = <<EOH
        SPARK_LOCAL_HOSTNAME="{{ env "attr.unique.network.ip-address" }}"
        SPARK_MASTER_IP="{{ env "attr.unique.network.ip-address" }}"
        SPARK_PUBLIC_DNS="{{ env "attr.unique.network.ip-address" }}"
        EOH
        destination = "secrets.env"
        env = true
      }
      env {
        SPARK_NO_DAEMONIZE = "true"
      }

      config {
        privileged = true
        image = "10.8.0.5:5000/spark-s3:0.0.3"
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
