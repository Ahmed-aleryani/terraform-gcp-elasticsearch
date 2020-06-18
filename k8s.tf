# k8s code resources created mainly for git@github.com:AckeeCZ/goproxie.git compatibility

resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {

    labels = {
      app = "elasticsearch"
    }

    namespace = var.namespace
    name      = "elasticsearch"
  }

  spec {
    selector {
      match_labels = {
        external-app = "elasticsearch"
      }
    }

    service_name = "elasticsearch"

    template {
      metadata {
        labels = {
          external-app = "elasticsearch"
        }
      }

      spec {
        container {
          name              = "elasticsearch"
          image             = "alpine/socat"
          image_pull_policy = "IfNotPresent"

          args = [
            "tcp-listen:9200,fork,reuseaddr",
            "tcp-connect:es-ilb.${google_compute_forwarding_rule.elasticsearch.name}.il7.${var.region}.lb.${var.project}.internal:80",
          ]
          port {
            protocol       = "TCP"
            container_port = 9200
            host_port      = 9200
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests {
              cpu    = "10m"
              memory = "10Mi"
            }
          }
        }
        termination_grace_period_seconds = 1
      }
    }
    update_strategy {
      type = "RollingUpdate"
      rolling_update {
        partition = 0
      }
    }
  }
}
