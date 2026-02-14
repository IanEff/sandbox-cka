# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration
CONFIG = {
  num_worker_nodes: Integer(ENV.fetch("SANDBOX_NUM_WORKER_NODES", "2")),
  control_plane_ip: ENV.fetch("SANDBOX_CONTROL_PLANE_IP", "192.168.56.10"),
  worker_ip_base: Integer(ENV.fetch("SANDBOX_WORKER_IP_BASE", "20")),

    # Optional local cache (APT + OCI registries) running on the macOS host.
  cache_enabled: ENV.fetch("SANDBOX_CACHE_ENABLED", "1") == "1",
  k8s_cache_enabled: ENV.fetch("SANDBOX_K8S_CACHE_ENABLED", "0") == "1",
  cache_host_vm: ENV.fetch("SANDBOX_CACHE_HOST_VM", "192.168.56.1"),
  cache_apt_port: ENV.fetch("SANDBOX_CACHE_APT_PORT", "3142"),
  cache_registry_dockerhub_port: ENV.fetch("SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT", "5001"),
  cache_registry_k8s_port: ENV.fetch("SANDBOX_CACHE_REGISTRY_K8S_PORT", "5002"),
  cache_registry_ghcr_port: ENV.fetch("SANDBOX_CACHE_REGISTRY_GHCR_PORT", "5003"),
  cache_registry_quay_port: ENV.fetch("SANDBOX_CACHE_REGISTRY_QUAY_PORT", "5004"),

  # Optional Features
  install_metrics_server: ENV.fetch("SANDBOX_INSTALL_METRICS_SERVER", "1") == "1",
  install_local_path_provisioner: ENV.fetch("SANDBOX_INSTALL_LOCAL_PATH_PROVISIONER", "1") == "1",
  install_ingress_nginx: ENV.fetch("SANDBOX_INSTALL_INGRESS_NGINX", "0") == "1",
  install_metallb: ENV.fetch("SANDBOX_INSTALL_METALLB", "1") == "1",
  install_longhorn: ENV.fetch("SANDBOX_INSTALL_LONGHORN", "0") == "1",
  install_gateway_api: ENV.fetch("SANDBOX_INSTALL_GATEWAY_API", "1") == "1",
  install_envoy_gateway: ENV.fetch("SANDBOX_INSTALL_ENVOY_GATEWAY", "0") == "1",
  install_argocd: ENV.fetch("SANDBOX_INSTALL_ARGOCD", "0") == "1",
  install_prometheus: ENV.fetch("SANDBOX_INSTALL_PROMETHEUS", "1") == "1",

  # CNI Plugin Selection: "flannel" (default), "cilium", "calico", "weavenet"
  cni_plugin: ENV.fetch("SANDBOX_CNI_PLUGIN", "cilium"),

  # Kubernetes Version (Minor)
  kubernetes_version_minor: ENV.fetch("SANDBOX_KUBERNETES_VERSION_MINOR", "1.34"),
}

Vagrant.configure("2") do |config|
  config.vm.box = "cloud-image/ubuntu-24.04"
  config.vm.box_check_update = false

  cache_env = {
    "SANDBOX_CACHE_ENABLED" => (CONFIG[:cache_enabled] ? "1" : "0"),
    "SANDBOX_K8S_CACHE_ENABLED" => (CONFIG[:k8s_cache_enabled] ? "1" : "0"),
    "SANDBOX_CACHE_HOST" => CONFIG[:cache_host_vm],
    "SANDBOX_CACHE_APT_PORT" => CONFIG[:cache_apt_port],
    "SANDBOX_CACHE_REGISTRY_DOCKERHUB_PORT" => CONFIG[:cache_registry_dockerhub_port],
    "SANDBOX_CACHE_REGISTRY_K8S_PORT" => CONFIG[:cache_registry_k8s_port],
    "SANDBOX_CACHE_REGISTRY_GHCR_PORT" => CONFIG[:cache_registry_ghcr_port],
    "SANDBOX_CACHE_REGISTRY_QUAY_PORT" => CONFIG[:cache_registry_quay_port],
    "SANDBOX_CNI_PLUGIN" => CONFIG[:cni_plugin],
    "SANDBOX_KUBERNETES_VERSION_MINOR" => CONFIG[:kubernetes_version_minor],
  }

  configure_virtualbox = lambda do |vm, name:, memory:, cpus:|
    vm.vm.provider "virtualbox" do |vb|
      vb.memory = memory
      vb.cpus = cpus
      vb.name = name
      # Ergonomic tweaks for macOS/VirtualBox
      vb.gui = false
      vb.linked_clone = false # Disable linked clones to prevent UUID conflicts during disk resizing
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--usb", "off"]

      # Workaround: Add shared folder definition directly to VBox to avoid Vagrant trying to mount it before GAs are installed
      vb.customize ["sharedfolder", "add", :id, "--name", "vagrant", "--hostpath", File.dirname(__FILE__), "--automount"]
    end

    # Modern native disk config (Vagrant 2.3+).
    # Add a secondary 20GB disk for extra storage (mounted to /data by common.sh)
    # - /data/containerd -> /var/lib/containerd (container images/data)
    # - /data/local-path-provisioner (PersistentVolume storage)
    vm.vm.disk :disk, size: "20GB", name: "container_data"

    # Disable default synced folder to prevent Vagrant from failing when GAs are missing
    vm.vm.synced_folder ".", "/vagrant", disabled: true
  end

  # Master Node
  config.vm.define "ubukubu-control" do |cp|
    cp.vm.hostname = "ubukubu-control"
    cp.vm.network "private_network", ip: CONFIG[:control_plane_ip]

    configure_virtualbox.call(cp, name: "ubukubu-control", memory: 4096, cpus: 4)

    cp.vm.provision "shell",
      path: "scripts/common.sh",
      env: cache_env

    cp.vm.provision "shell", path: "scripts/control-plane.sh", env: cache_env

    if CONFIG[:install_metrics_server]
      cp.vm.provision "shell", path: "scripts/install_metrics_server.sh", env: cache_env
    end

    if CONFIG[:install_local_path_provisioner]
      cp.vm.provision "shell", path: "scripts/install_local_path_provisioner.sh", env: cache_env
    end

    if CONFIG[:install_metallb]
      cp.vm.provision "shell", path: "scripts/install_metallb.sh", env: cache_env
    end

    if CONFIG[:install_ingress_nginx]
      cp.vm.provision "shell", path: "scripts/install_ingress_nginx.sh", env: cache_env
    end

    if CONFIG[:install_longhorn]
      cp.vm.provision "shell", path: "scripts/install_longhorn.sh", env: cache_env
    end

    if CONFIG[:install_envoy_gateway]
      cp.vm.provision "shell", path: "scripts/install_envoy_gateway.sh", env: cache_env
    end

    if CONFIG[:install_argocd]
      cp.vm.provision "shell", path: "scripts/install_argocd.sh", env: cache_env
    end

    if CONFIG[:install_prometheus]
      cp.vm.provision "shell", path: "scripts/install_prometheus.sh", env: cache_env
    end

    # Install specific Etcd tools (etcdutl, etcd server binary) not provided by simple apt packages
    cp.vm.provision "shell", path: "scripts/install_etcd_tools.sh", env: cache_env
  end

  # Worker Nodes
  (1..CONFIG[:num_worker_nodes]).each do |i|
    config.vm.define "ubukubu-node-#{i}" do |node|
      node.vm.hostname = "ubukubu-node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{CONFIG[:worker_ip_base] + i}" # e.g., 192.168.56.21

      configure_virtualbox.call(node, name: "ubukubu-node-#{i}", memory: 3072, cpus: 3)

      node.vm.provision "shell",
        path: "scripts/common.sh",
        env: cache_env
      node.vm.provision "shell", path: "scripts/node.sh", env: cache_env
    end
  end

end
