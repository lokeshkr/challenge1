main.tf

provider "google" {
            project     = "var.projectID"
            region      = "var.region"
        }


  # *****************************  load balancing ***************************************

resource "google_compute_managed_ssl_certificate" "web-ssl-certificate" {
                name = "ttw-cert"
                managed {
                    domains = ["{{var.load_balancer_ssl_certificate_domain_name}}"]
                }
        }

resource "google_service_account_iam_member" "cloud-users-access-to-service-account" {
            service_account_id = "$${google_service_account.web_server_service_account.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }
resource "google_project_iam_binding" "loadbalancer_access"
resource "google_project_iam_binding" "cloud_armor_access"
resource "google_project_iam_binding" "compute_access" 
resource "google_compute_firewall" "health_check_firewall"

resource "google_compute_global_forwarding_rule" "ttw-https-global-forwarding-rule"{
                name = "ttw-https-forwarding-rule"
                target = "$${google_compute_target_https_proxy.ttw-https-target-proxy.id}"
                port_range = "443"
                # Ephemeral IP address will be auto created. Uncomment and provide self link of custom external IP
                # ip_address =
                load_balancing_scheme = "EXTERNAL"
        }
resource "google_compute_target_https_proxy" "ttw-https-target-proxy" {
                name = "ttw-target-proxy"
                url_map = "$${google_compute_url_map.ttw-url-map.id}"
                ssl_certificates = "$${[google_compute_managed_ssl_certificate.ttw-ssl-certificate.id]}"
        }  



        # *****************************  Cloud Armor ***************************************
 resource "google_compute_security_policy" "policy" {
            name = "{{var.cloud_armor_security_policy_name}}cloud-armor-security-policy"
            # Default rule to deny traffic from internet
            rule {
                action   = "deny(403)"
                priority = "2147483647"
                match {
                    versioned_expr = "SRC_IPS_V1"
                    config {
                        src_ip_ranges = ["*"]
                    }
                }
                description = "default rule"
            }
            #user can configure rules to evaluate more preconfigured expressions
            rule {
                action   = "deny(403)"
                priority = "1000"
                match {
                    expr {
                        expression= "evaluatePreconfiguredExpr('xss-canary')"
                    }
                }
                description = "Deny access to XSS attempts"
            }
            # Custom rule to allow specific IPs(whitelisting)
            rule {
                action   = "allow"
                priority = "500"
                match {
                    versioned_expr = "SRC_IPS_V1"
                    config {
                        src_ip_ranges = [
                            "{{.cloud_armor_security_policy_allow_range}}"
                        ]
                    }
                }
                description = "allow only from Specific range"
            }
        }
        
 # *****************************  Cloud SQL ***************************************
resources = {
        cloud_sql_instances = [{
            name               = "{{var.private_cloud_sql_name}}"
            resource_name      = "ttw_sql_instance"
            type               = "mysql"
            network_project_id = "{{var.web_project_id}}"
            network            = "{{var.vpc_network_name}}"
            tier               = "{{var.private_cloud_sql_machine_type}}"
            labels = {
                component = "database"
                data_type = "{{var.mig_instance_datatype_label}}"
                data_criticality = "{{var.mig_instance_data_criticality_label}}"
            }
resource "google_project_iam_binding" "cloud_sql_access" {
            project = "{{var.web_project_id}}"
            role    = "roles/cloudsql.editor"
            members = [
                "group:{{var.cloud_users_group}}",
            ]
        }

 # *****************************  Gke ***************************************
 resource "google_project_iam_binding" "gke_access" {
            project = "{{.ttw_project_id}}"
            role    = "roles/container.developer"
            members = [
                "group:{{var.cloud_users_group}}",
            ]
        }


gke_clusters = [{
            name                   = "{{var.gke_private_cluster_name}}"
            resource_name          = "web_gke-cluster"
            network_project_id     = "{{var.ttw_project_id}}"
            network                = "{{var.vpc_network_name}}"
            subnet                 = "{{var.gke_subnet_name}}"  
            ip_range_pods_name     = "gke-subnet-secondary-pod-range"
            ip_range_services_name = "gke-subnet-secondary-service-range"
            master_ipv4_cidr_block = "{{var.gke_private_master_ip_range}}"
#Code Block 3.2.6.c
            node_pools = [
                {
                name              = "{{var.gke_node_pool_name}}"
                machine_type      = "{{var.gke_node_pool_machine_type}}"
                min_count         = {{var.gke_node_pool_min_instance_count}}
                max_count         = {{var.gke_node_pool_max_instance_count}}
                disk_size_gb      = {{var.gke_node_pool_instance_disk_size}}
                #Uncomment the following parameters to customize node pool
                #disk_type         = 
                #accelerator_count = 
                #accelerator_type  = 
                image_type        = "{{var.gke_node_pool_image_type}}"
                #uncomment to enable auto_repair. Default is false
                #auto_repair       = true
                auto_upgrade    = true
               }
            ]
# Storage bucket used to export 
        storage_buckets = [{
            name = "{{.cloud_sql_backup_export_bucket_name}}"
            resource_name = "ttw_cloud_sql_backup_export_bucket"
            labels = {
                data_type = "{{.mig_instance_datatype_label}}"
                data_criticality = "{{.mig_instance_data_criticality_label}}"
            }

