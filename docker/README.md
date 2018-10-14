---
version: v0.1.2
---
# Building Image
```
docker build -t helmsman-no-ns .
```
# Running Built Image

```
docker run -v $(pwd):/tmp --rm -it \
-e KUBECTL_PASSWORD=<k8s_password> \
-e AWS_ACCESS_KEY_ID=<aws_key_id> \
-e AWS_DEFAULT_REGION=<aws_region> \
-e AWS_SECRET_ACCESS_KEY=<acess_key> \
helmsman-no-ns \
helmsman -debug -apply -f <your_desired_state_file>.<toml|yaml>
```
# Running Built Image with heptio authenticator (OSX)
docker run -it --rm \
-e "KUBECONFIG=/root/.kube/config" \
-v /Users/YourHomeDirectory/.aws:/root/.aws \
-v /Users/YourHomeDirectory/.kube:/root/.kube \
-v $PWD:/tmp helmsman-no-ns helmsman -v

Check the different offical image tags created by Praqma on [Dockerhub](https://hub.docker.com/r/praqma/helmsman/)
