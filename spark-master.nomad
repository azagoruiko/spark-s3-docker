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

    task "spark-master-task" {
      driver = "docker"

      env {
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/nfs/docker"
      }

      config {
        privileged = true
        image = "127.0.0.1:9999/docker/spark-master:0.0.1"
        command = "bash"
        args = [
          "/opt/spark/sbin/start-master.sh",
        ]

        port_map {
          web = 8080
        }

        volumes = [
          "/var/nfs/:/var/nfs/",
        ]
      }

      resources {
        cpu    = 1000
        memory = 1000
      }

      service {
        name = "spark-master"
        port = "web"
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
