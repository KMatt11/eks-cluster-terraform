###### root/kubernetes.tf

resource "kubernetes_deployment" "luit22" {
  metadata {
    name = "terraform-luit22"
    labels = {
      test = "Myluit22App"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        test = "Myluit22App"
      }
    }
    template {
      metadata {
        labels = {
          test = "Myluit22App"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "luit22"

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
        }
      }
    }
  }
}

resource "kubernetes_service" "luit22" {
  metadata {
    name = "terraform-luit22"
  }

  spec {
    selector = {
      test = "myluit22App"
    }
    port {
      port        = 80
      target_port = 80
      node_port   = 30010
    }

    type = "LoadBalancer"
  }
}