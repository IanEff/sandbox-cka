#!/bin/bash
if [[ ! -f /home/vagrant/apiserver-manifest.yaml ]]; then echo "File missing"; exit 1; fi
grep "kind: Pod" /home/vagrant/apiserver-manifest.yaml
grep "name: kube-apiserver" /home/vagrant/apiserver-manifest.yaml
