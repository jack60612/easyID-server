# easyID-server

compreface server + api for easyID

## Installation

1. Install [Docker](https://docs.docker.com/get-docker/), [Kubernetes](https://kubernetes.io/docs/tasks/tools/) (kubectl) and [Helm](https://helm.sh/docs/intro/install/) Or Install [MicroK8s](https://microk8s.io/) (Recommended)
If Using Microk8s, enable the following addons:

```bash
microk8s enable dns hostpath-storage ingress
```

2. Optional: Connect to existing Kubernetes cluster (IF more than one machine)
3. !!! IMPORTANT !!!: For persistent data, add a label called `easyID` with a value of `main-node` to the node you want to store the db on:
`kubectl label nodes <node-name> easyID=main-node` You can get the name by running `kubectl get nodes`.
4. Clone this repository
5. Make db directory: `mkdir /opt/easyID/`
6. Run `kubectl create namespace easyid`
7. Connect to gh container registry: `docker login ghcr.io` & connect kube to gh container registry:

    ```bash
    kubectl -n easyid create secret docker-registry ghregistrycred --docker-server=ghcr.io --docker-username=jack60612 --docker-password=<github-personal-access-token> --docker-email=jack@jacknelson.xyz
    ```

8. Create a tls secret for the ingress:

    ```bash
    kubectl create secret tls easyid-tls \
        --namespace easyid \
        --key main-nginx/nginx-selfsigned.key \
        --cert main-nginx/nginx-selfsigned.crt
    ```

9. Run `helm install easyid-kubernetes ./helm-config --namespace easyid`
11. [Login](https://localhost) to the admin panel and create an account + needed api keys.

## Uninstall

1. Run `helm delete easyid-kubernetes -n easyid --wait`
2. Delete the namespace `kubectl delete namespace easyid`

### TODO

- [x] Fully test new proxy.
- [x] Do more tests with multiple api's and core components.
- [x] Make changing ports compatible with the ui proxy & the 2nd nginx instance.
- [x] add CI/CD
- [ ] Finish Python API

## Updating

To update the server after a new upstream release:

1. Check the [upstream release notes](https://github.com/exadel-inc/CompreFace/releases) for any breaking changes.
2. Update the `appVersion` in `Chart.yaml` to the new version.
3. Update the `image.tag` for all upstream images in `values.yaml` to the new version.
4. Check main-nginx and make sure the `main.conf.template` file is matching the settings in Upstream: `ui/nginx/templates/nginx.conf.template`.
5. Update the docker config in the core folder. [Upstream](https://github.com/exadel-inc/CompreFace/tree/master/embedding-calculator) and update the build args.
6. Push Update via Helm:

```commandline
helm upgrade easyid-kubernetes ./helm-config --namespace easyid
```
