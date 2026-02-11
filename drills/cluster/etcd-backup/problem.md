# ETCD Backup

Perform a snapshot backup of the etcd database.
1. Save the snapshot to `/home/vagrant/etcd-snapshot.db`.
2. Use the certificates located in `/etc/kubernetes/pki/etcd/`.
   - CA: `ca.crt`
   - Cert: `server.crt`
   - Key: `server.key`
3. Ensure you use API version 3.
