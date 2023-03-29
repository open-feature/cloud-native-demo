# OpenFeature ArgoCD Demo

This demo showcases how the OpenFeature Operator allows to integrate with ArgoCD to control feature flags 
in a GitOps environment. Using the `FeatureFlagConfiguration` CRD which lives in the application's GitOps 
reppository, features can be enabled/disabled by creating a pull request for the GitOps repository. Once a PR has been merged,
ArgoCD will pick up that change and automatically apply the updated configuration. 
Changes for a feature flag will be immediately reflected in the demo application, without the need to restart the pod running the application.
This is enabled by a Grpc event stream between the application and the flagd instance injected by the OpenFeature Operator. This event stream will
notify the application about any changes that have been made to a feature flag.

*Note:* Until https://github.com/open-feature/open-feature-operator/issues/371 has been implemented in the OpenFeature Operator, the  event stream based
client-side feature flagging is enabled by an nginx container within the pod running the application. This container can be accessed via a `flagd-service` Kubernetes service
and will proxy all flagd requests to the flagd container injected by the OpenFeature Operator.

## Setting up the Demo

To setup the demo, you must be connected to a K8s cluster (this demo has been tested on Kubernetes version `v1.25.6`).
To install everything, use the following command:

```shell
make install-environment GITOPS_REPO="<gitops repo url>"
```

This will install everything you need to deploy the demo application. The installed components are:

1. *Cert-manager:* Required by the OpenFeature Operator
1. *OpenFeature Operator*: Will inject the flagd sidecar into the application's pod
1. *ArgoCD:* Will watch the GitOps repository and apply any changes once they have been merged into the main branch

In addition to deploying these three components, an ArgoCD `Application` will be created. This will ensure that ArgoCD is 
watching the GitOps repo you specify using the `GITOPS_REPO` parameter for the `make install-environment` command.

You can afterwards also login to ArgoCD to check if the Application has been created and view its sync status:

1. Create a port-forward to the `argocd-server`. This can be done using: 

```shell
make port-forward-argo
```

Running this command will make ArgoCD accessibla via [](http://localhost:8081). When accessing ArgoCD, you will be prompted to enter your credentials.
Those are auto generated when ArgoCD is installed, and can be retrieved using the `argocd` CLI, using the following command:

```
argocd admin initial-password -n argocd
```

This will give you the login password for ArgoCD. The user name is `admin`.

Once logged in to the ArgoCD UI, you should see the `openfeature-demo` application:

![Application overview](assets/applications-overview.png)

This application will be automatically synced every 30 seconds, so you should also see the deployment of the sample application, as well as a `Jaeger` instance in the `open-feature-demo` namespace. 

```shell
$ kubectl get all -n open-feature-demo

NAME                                                           READY   STATUS    RESTARTS   AGE
pod/open-feature-demo-go-feature-flag-proxy-5f969dbd4c-9k6rk   1/1     Running   0          3h22m
pod/open-feature-demo-jaeger-agent-75b58df947-n4n85            1/1     Running   0          3h22m
pod/open-feature-demo-playground-app-65449d5444-q8vph          3/3     Running   0          153m
pod/open-feature-fib-service-6c7b76d997-zk2z5                  2/2     Running   0          3h22m

NAME                                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/flagd-service                      ClusterIP   192.168.62.139   <none>        8013/TCP    172m
service/open-feature-demo-goff-service     ClusterIP   192.168.49.26    <none>        1031/TCP    3h22m
service/open-feature-demo-jaeger-service   ClusterIP   192.168.58.66    <none>        6832/UDP    3h22m
service/open-feature-demo-jaeger-ui        ClusterIP   192.168.53.254   <none>        80/TCP      3h22m
service/open-feature-demo-service          ClusterIP   192.168.57.102   <none>        80/TCP      3h22m
service/open-feature-fibonacci-service     ClusterIP   192.168.61.80    <none>        30002/TCP   3h22m

NAME                                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/open-feature-demo-go-feature-flag-proxy   1/1     1            1           3h22m
deployment.apps/open-feature-demo-jaeger-agent            1/1     1            1           3h22m
deployment.apps/open-feature-demo-playground-app          1/1     1            1           3h22m
deployment.apps/open-feature-fib-service                  1/1     1            1           3h22m

NAME                                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/open-feature-demo-go-feature-flag-proxy-5f969dbd4c   1         1         1       3h22m
replicaset.apps/open-feature-demo-jaeger-agent-75b58df947            1         1         1       3h22m
replicaset.apps/open-feature-demo-playground-app-65449d5444          1         1         1       172m
replicaset.apps/open-feature-fib-service-6c7b76d997                  1         1         1       3h22m
```

To access the playground application, create a port-forward using the following command:

```shell
make port-forward-playground
```

This wil make the playground app accessible via [](http://localhost:8085).

## Changing a Feature Flag via PR

To demonstrate the change of a flag using a PR, adapt one of the flags in the file `deployment/flagd-flag-spec.yaml` and commit/push those changes to a 
branch of the GitOps repository, e.g.: 
