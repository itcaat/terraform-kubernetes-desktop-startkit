resource "kubernetes_namespace" "grafana" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }
      spec {
        container {
          image = "grafana/grafana:${var.image_tag}"
          name  = var.name
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name = var.name
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.name
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name = var.name
    namespace = var.namespace
    annotations = {
      "cert-manager.io/cluster-issuer" = var.issuer_name
    }
  }
  spec {
    ingress_class_name = var.ingress_class_name
    tls {
      hosts       = [var.host]
      secret_name = "${var.name}-tls"
    }
    rule {
      host = var.host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
