# easyID-server
 compreface server + api for easyID

## Installation:
1. Install [Docker](https://docs.docker.com/get-docker/), [Kubernetes](https://kubernetes.io/docs/tasks/tools/) (kubectl) and [Helm](https://helm.sh/docs/intro/install/)
2. Optional: Connect to existing Kubernetes cluster (IF more than one machine)
3. !!! IMPORTANT !!!: For persistent data, add a label called `easyID` with a value of `main-node` to the node you want to store the db on:
`kubectl label nodes <node-name> easyID=main-node` You can get the name by running `kubectl get nodes`.
4. Clone this repository
5. Make db directory: `mkdir /opt/easyID/`
6. Connect to gh container registry: `docker login ghcr.io` & connect kube to gh container registry: 
``kubectl -n compreface create secret docker-registry ghregistrycred --docker-server=ghcr.io --docker-username=jack60612
--docker-password=<github-personal-access-token>  --docker-email=jack@jacknelson.xyz``
7. Run ` helm install compreface-kubernetes ./helm-config --namespace compreface --create-namespace`
8. [Login](https://localhost) to the admin panel and create an account + needed api keys.

## Uninstall:
1. Run `helm delete compreface-kubernetes -n compreface`
2. Delete the namespace `kubectl delete namespace compreface`

### TODO:
- [x] Fully test new proxy.
- [x] Do more tests with multiple api's and core components.
- [x] Make changing ports compatible with the ui proxy & the 2nd nginx instance.
- [x] add CI/CD
- [ ] Finish Python API


## Updating:
To update the server after a new upstream release:
1. Check the [upstream release notes](https://github.com/exadel-inc/CompreFace/releases) for any breaking changes.
2. Update the `appVersion` in `Chart.yaml` to the new version.
3. Update the `image.tag` for all upstream images in `values.yaml` to the new version.
4. Check main-nginx and make sure the `main.conf.template` file is matching the settings in Upstream: `ui/nginx/templates/nginx.conf.template`.
5. Push Update via Helm:
```commandline
helm upgrade compreface-kubernetes ./helm-config --namespace compreface
```