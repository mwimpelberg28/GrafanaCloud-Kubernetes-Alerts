resource "grafana_rule_group" "rule_group_8cb50f3c648c3ea7" {
  name             = "1m"
  folder_uid       = var.folder_uid
  interval_seconds = 60

  rule {
    name      = "KubePodCrashLooping"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"max_over_time(kube_pod_container_status_waiting_reason{reason=\\\"CrashLoopBackOff\\\", job!=\\\"\\\"}[5m]) >= 1\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is in waiting state (reason: \"CrashLoopBackOff\")."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepodcrashlooping"
      summary     = "Pod is crash looping."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubePodNotReady"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"sum by (namespace, pod, job, cluster) (\\n  max by(namespace, pod, job, cluster) (\\n    kube_pod_status_phase{job!=\\\"\\\", phase=~\\\"Pending|Unknown|Failed\\\"}\\n  ) * on(namespace, pod, cluster) group_left(owner_kind) topk by(namespace, pod, cluster) (\\n    1, max by(namespace, pod, owner_kind, cluster) (kube_pod_owner{owner_kind!=\\\"Job\\\"})\\n  )\\n) > 0\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a non-ready state for longer than 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepodnotready"
      summary     = "Pod has been in a non-ready state for more than 15 minutes."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeDeploymentGenerationMismatch"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_deployment_status_observed_generation{job!=\\\"\\\"}\\n  !=\\nkube_deployment_metadata_generation{job!=\\\"\\\"}\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment }} does not match, this indicates that the Deployment has failed but has not been rolled back."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentgenerationmismatch"
      summary     = "Deployment generation mismatch due to possible roll-back"
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeDeploymentReplicasMismatch"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"(\\n  kube_deployment_spec_replicas{job!=\\\"\\\"}\\n    >\\n  kube_deployment_status_replicas_available{job!=\\\"\\\"}\\n) and (\\n  changes(kube_deployment_status_replicas_updated{job!=\\\"\\\"}[10m])\\n    ==\\n  0\\n)\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentreplicasmismatch"
      summary     = "Deployment has not matched the expected number of replicas."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeDeploymentRolloutStuck"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_deployment_status_condition{condition=\\\"Progressing\\\", status=\\\"false\\\",job!=\\\"\\\"}\\n!= 0\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Rollout of deployment {{ $labels.namespace }}/{{ $labels.deployment }} is not progressing for longer than 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentrolloutstuck"
      summary     = "Deployment rollout is not progressing."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeStatefulSetReplicasMismatch"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"(\\n  kube_statefulset_status_replicas_ready{job!=\\\"\\\"}\\n    !=\\n  kube_statefulset_status_replicas{job!=\\\"\\\"}\\n) and (\\n  changes(kube_statefulset_status_replicas_updated{job!=\\\"\\\"}[10m])\\n    ==\\n  0\\n)\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetreplicasmismatch"
      summary     = "StatefulSet has not matched the expected number of replicas."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeStatefulSetGenerationMismatch"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_statefulset_status_observed_generation{job!=\\\"\\\"}\\n  !=\\nkube_statefulset_metadata_generation{job!=\\\"\\\"}\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetgenerationmismatch"
      summary     = "StatefulSet generation mismatch due to possible roll-back"
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeStatefulSetUpdateNotRolledOut"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"(\\n  max by(namespace, statefulset, job, cluster) (\\n    kube_statefulset_status_current_revision{job!=\\\"\\\"}\\n      unless\\n    kube_statefulset_status_update_revision{job!=\\\"\\\"}\\n  )\\n    *\\n  (\\n    kube_statefulset_replicas{job!=\\\"\\\"}\\n      !=\\n    kube_statefulset_status_replicas_updated{job!=\\\"\\\"}\\n  )\\n)  and (\\n  changes(kube_statefulset_status_replicas_updated{job!=\\\"\\\"}[5m])\\n    ==\\n  0\\n)\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetupdatenotrolledout"
      summary     = "StatefulSet update has not been rolled out."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeDaemonSetRolloutStuck"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"KubeDaemonSetRolloutStuck\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has not finished or progressed for at least 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetrolloutstuck"
      summary     = "DaemonSet rollout is stuck."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeContainerWaiting"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"sum by (namespace, pod, container, job, cluster) (kube_pod_container_status_waiting_reason{job!=\\\"\\\"}) > 0\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "pod/{{ $labels.pod }} in namespace {{ $labels.namespace }} on container {{ $labels.container}} has been in waiting state for longer than 1 hour."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubecontainerwaiting"
      summary     = "Pod container waiting longer than 1 hour"
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeDaemonSetNotScheduled"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_daemonset_status_desired_number_scheduled{job!=\\\"\\\"}\\n  -\\nkube_daemonset_status_current_number_scheduled{job!=\\\"\\\"} > 0\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetnotscheduled"
      summary     = "DaemonSet pods are not scheduled."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeDaemonSetMisScheduled"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_daemonset_status_number_misscheduled{job!=\\\"\\\"} > 0\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetmisscheduled"
      summary     = "DaemonSet pods are misscheduled."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeJobNotCompleted"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"time() - max by(namespace, job_name, cluster) (kube_job_status_start_time{job!=\\\"\\\"}\\n  and\\nkube_job_status_active{job!=\\\"\\\"} > 0) > 43200\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Job {{ $labels.namespace }}/{{ $labels.job_name }} is taking more than {{ \"43200\" | humanizeDuration }} to complete."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubejobnotcompleted"
      summary     = "Job did not complete in time"
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeJobFailed"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_job_failed{job!=\\\"\\\"}  > 0\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete. Removing failed job after investigation should clear this alert."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubejobfailed"
      summary     = "Job failed to complete."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeHpaReplicasMismatch"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"(kube_horizontalpodautoscaler_status_desired_replicas{job!=\\\"\\\"}\\n  !=\\nkube_horizontalpodautoscaler_status_current_replicas{job!=\\\"\\\"})\\n  and\\n(kube_horizontalpodautoscaler_status_current_replicas{job!=\\\"\\\"}\\n  >\\nkube_horizontalpodautoscaler_spec_min_replicas{job!=\\\"\\\"})\\n  and\\n(kube_horizontalpodautoscaler_status_current_replicas{job!=\\\"\\\"}\\n  <\\nkube_horizontalpodautoscaler_spec_max_replicas{job!=\\\"\\\"})\\n  and\\nchanges(kube_horizontalpodautoscaler_status_current_replicas{job!=\\\"\\\"}[15m]) == 0\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler  }} has not matched the desired number of replicas for longer than 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubehpareplicasmismatch"
      summary     = "HPA has not matched desired number of replicas."
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
  rule {
    name      = "KubeHpaMaxedOut"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"kube_horizontalpodautoscaler_status_current_replicas{job!=\\\"\\\"}\\n  ==\\nkube_horizontalpodautoscaler_spec_max_replicas{job!=\\\"\\\"}\\n\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      description = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler  }} has been running at max replicas for longer than 15 minutes."
      runbook_url = "https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubehpamaxedout"
      summary     = "HPA is running at max replicas"
    }
    is_paused = false

    notification_settings {
      contact_point = var.contact_point
      group_by      = null
      mute_timings  = null
    }
  }
}
