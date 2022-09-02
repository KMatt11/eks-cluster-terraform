###### root/kubernetes.tf

resource "kubernetes_deployment" "KP" {
  metadata {
    name = "terraform-KP"
    labels = {
      test = "MyKPApp"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "MyKPApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyKPApp"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "KP"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 1
            period_seconds        = 1
          }
        }
      }
    }
  }
}