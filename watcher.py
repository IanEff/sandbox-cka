#!/usr/bin/env python3
from kubernetes import client, config, watch
import json, os, sys

try:
    config.load_incluster_config()
except config.ConfigException:
    print("In-cluster config not found, trying kubeconfig file.")
    config.load_kube_config()

group = os.environ.get('WATCH_GROUP', 'bookofkubernetes.com')
version = os.environ.get('WATCH_VERSION', 'v1')
resource = os.environ.get('WATCH_RESOURCE', 'samples')
api = client.ClustomObjectsApi()

w = watch.Watch()
for event in w.stream(api.list_cluster_custom_object, group, version, resource):
    json.dump(event, sys.stdout, indent=2)
    sys.stdout.flush()