provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "local_file" "applications" {
  filename = "${path.module}/applications.json"
}

locals {
  applications = jsondecode(data.local_file.applications.content).applications
}

resource "kubernetes_deployment" "app" {
  for_each = { for app in local.applications : app.name => app }


  metadata {
    name = each.key
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = each.key
      }
    }

    template {
      metadata {
        labels = {
          app = each.key
        }
      }

      spec {
        container {
          name  = each.key
          image = each.value.image
          
         args = [
           "-listen=:${each.value.port}",
           "-text=\"I am ${each.key}\""
          ]

          port {
            container_port = each.value.port
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  for_each = kubernetes_deployment.app

  metadata {
    name = each.key
  }

  spec {
    selector = {
      app = each.key
    }

    port {
      port        = 80
      target_port = each.value.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "primary" {
for_each = { for app in slice(local.applications, 0, 1) : app.name => app if app.traffic_weight != "100" }

metadata {
    name        = "primary-ingress-${each.key}"
    annotations = {
    "kubernetes.io/elb.port": "80"
    }
}

spec {
  ingress_class_name = "nginx"
    
  rule {
      host = "www.example.io"
      http {
        path {
          path = "/"
          backend {
            service {
              name = each.value.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "canary" {
for_each = { for app in slice(local.applications, 1, length(local.applications)) : app.name => app if app.traffic_weight != "100" }

metadata {
    name        = "canary-ingress-${each.key}"
    annotations = {
    "nginx.ingress.kubernetes.io/canary": "true" 
    "nginx.ingress.kubernetes.io/canary-weight" = each.value.traffic_weight
    "nginx.ingress.kubernetes.io/canary-by": "weight"
    "kubernetes.io/elb.port": 80
    }
}

spec {
  ingress_class_name = "nginx"
    
    # default_backend {
    #   service {
    #     name = each.value.name
    #     port {
    #       number = 80
    #     }
    #   }
    # }  
    
  rule {
      host = "www.example.io"
      http {
        path {
          path = "/"
          backend {
            service {
              name = each.value.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
