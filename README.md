# K3S Image Cleaner
The idea behind this repository is to provide an easy way to remove any dangling images from the k3s node to free up some precious space.

# Considerations
The container is build upon the [alpine](https://hub.docker.com/_/alpine) image, so it's very lightweight.  
There is only one bash script that performs the `crictl rmi --prune` command.  
The only way to make it work is to run the container in privileged mode, otherwise the `crictl` command will fail.  

With that in mind, if you would rather NOT have a privileged container running on your node, you can always run the script manually (or via cron) on the node itself.

**And as always**, please browse through the code before actually deploying it on your nodes.  

### I have no malicious intent, but you should always be careful when running someone else's code on your infrastructure.

# Configuration
There are only two environment variables that you can set (in the `k3s/daemonset.yaml`):
1. `CLEANUP_HOUR` - the hour of the day when the cleanup should be performed (default: 2)
2. `CLEANUP_MINUTE` - the minute of the hour when the cleanup should be performed (default: 0)

These are the variables which define the time when the cleanup should be performed.
After the cleanup is performed, script will sleep for the next 23 hours (to give a lee-way for the possible time drifts).  
After the 23 hours sleep, script will start checking every minute if the current time matches the cleanup time.

# Building
You can manually build the image if you wish to do so.  
The script which performs the cleanup and the Dockerfile are located in the `docker` directory.

Simply run the following commands inside the `docker` directory:
```bash
docker build -t _your_name_/_iamge_name_:_tag_name_ .
docker push _your_name_/_iamge_name_:_tag_name_
```

# Deploying
To deploy the daemonset, simply run the following command inside the `k3s` directory:
```bash
kubectl apply -f daemonset.yaml
```

Depending on the amount of nodes you have, it might take a while for the daemonset to be deployed on all of them.  

After the daemonset is deployed, it will span across all of your nodes and will perform the cleanup at the specified time.

Important to note, that it will be only deployed on the `runner` nodes, so it will (at least shoud) stay away from your master node(s).