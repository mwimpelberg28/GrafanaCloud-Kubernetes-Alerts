# Default Kubernetes Alerts with Terraform  

This repository provides Terraform code to deploy default Kubernetes alerts for monitoring cluster health, and workload stability. These alerts are designed to work with Prometheus and Grafana, providing critical notifications for maintaining a stable Kubernetes environment.

---

## Features  
- Deploys a comprehensive set of Kubernetes alert rules for:
  - **Pod health**
  - **Daemonset health**
  - **StatefulSet health**

- Customizable thresholds for alert rules.
- Supports integration with Alertmanager for notifications.

---

## Prerequisites  
- **Terraform**
- **Kubernetes Integration in Grafana**
- **Service Account API Key**
---

## Getting Started  

### Clone the Repository  
```bash
git clone https://github.com/yourusername/kubernetes-alerts-terraform.git
cd kubernetes-alerts-terraform
```

### Update provider information with API key

### Update variables to match your enviornment

### Apply Code
```bash
terraform init
terraform apply
```