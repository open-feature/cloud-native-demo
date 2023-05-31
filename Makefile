GITOPS_REPO ?= https://github.com/open-feature/cloud-native-demo

cleanup-environment: uninstall-ofo uninstall-argo

install-environment-with-ingress: install-ofo install-argo create-argo-app install-ingress

install-environment: install-ofo install-argo create-argo-app

install-ofo:
	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml
	kubectl wait --timeout=60s --for=condition=Available=True deploy --all -n 'cert-manager'
	kubectl apply -f environment/ofo/ofo.yaml
	kubectl wait --timeout=60s --for=condition=Available=True deploy --all -n 'open-feature-operator-system'

uninstall-ofo:
	kubectl delete -f environment/ofo/ofo.yaml

install-argo:
	kubectl create namespace argocd
	kubectl -n argocd apply -f environment/argo/argo.yaml
	kubectl wait --timeout=60s --for=condition=Available=True deploy --all -n 'argocd'

install-ingress:
	kubectl apply -f environment/ingress/ingress.yaml
	./scripts/setup-ingress-address.sh

create-argo-app:
	sed 's~{{GITOPS_REPO}}~$(GITOPS_REPO)~g' environment/argo/app.yaml > environment/argo/app_tmp.yaml
	kubectl -n argocd apply -f environment/argo/app_tmp.yaml
	rm environment/argo/app_tmp.yaml

uninstall-argo:
	kubectl delete namespace argocd

port-forward-jaeger:
	@echo ""
	@echo "Open Jaeger in your Browser: http://localhost:8082"
	@echo "CTRL-c to stop port-forward"

	@echo ""
	kubectl port-forward -n open-feature-demo svc/open-feature-demo-jaeger-ui 8082:80

port-forward-playground:
	@echo ""
	@echo "Open the Playground App in your Browser: http://localhost:8085"
	@echo "CTRL-c to stop port-forward"

	@echo ""
	kubectl port-forward -n open-feature-demo svc/flagd-service 8013:80 & 
	kubectl port-forward -n open-feature-demo svc/open-feature-demo-service 8085:80

port-forward-argo:
	@echo ""
	@echo "Open Argo in your Browser: http://localhost:8081"
	@echo "CTRL-c to stop port-forward"

	@echo ""
	kubectl port-forward -n argocd svc/argocd-server 8081:80

get-argo-login:
	argocd admin initial-password -n argocd

get-ingress-address:
	@./scripts/get-ingress-address.sh
