resource "kubernetes_namespace" "echo" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "echo" {
  depends_on = [kubernetes_namespace.echo]
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
          image = local.image
          name  = var.name
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  depends_on = [kubernetes_namespace.echo]
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.name
    }
    port {
      protocol    = "TCP"
      port        = 3000
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "echo" {
  depends_on = [kubernetes_namespace.echo]
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "cert-manager.io/cluster-issuer" = var.issuer_name
    }
  }
  spec {
    ingress_class_name = var.ingress_class_name
    tls {
      hosts       = [var.hostname]
      secret_name = local.secret_name
    }
    rule {
      host = var.hostname
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
