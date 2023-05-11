job "spark-small-workers-job" {
  datacenters = ["home"]
  type        = "service"
  constraint {
    attribute = "${node.class}"
    value     = "guestworker"
  }
  group "spark-small-workers-group" {
    count = 2
    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

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
    }

    task "spark-small-workers-task" {
      driver = "docker"
      env {
        SPARK_NO_DAEMONIZE = "true"
      }
      template {
        data = <<EOH
        {{ range service "spark-master" }}
        SPARK_MASTER=spark://{{ .Address }}:7077
        {{ end }}
        SPARK_PUBLIC_DNS="{{ env "attr.unique.network.ip-address" }}"
        EOH
        destination = "local/file.env"
        env         = true
      }

      config {
        privileged = true
        image = "10.8.0.5:5000/spark-s3:0.0.3"
        command = "bash"
        args = [
          "/opt/spark/work-dir/run_workers.sh",
        ]

        ports = ["ui"]
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
