install-environment: install-ofo install-argo

install-ofo:
	kubectl apply -f environment/ofo/ofo.yaml

install-argo:
	kubectl create namespace argocd
	kubectl -n argocd apply -f environment/argo/argo.yaml

uninstall-argo:
	kubectl delete namespace argocd

port-forward-jaeger:
	@echo ""
	@echo "Open Jaeger in your Browser: http://localhost:16686"
	@echo "CTRL-c to stop port-forward"

	@echo ""
	kubectl port-forward -n open-feature-demo svc/open-feature-demo-jaeger-ui 16686

port-forward-playground:
	@echo ""
	@echo "Open the Playground App in your Browser: http://localhost:30000"
	@echo "CTRL-c to stop port-forward"

	@echo ""
	kubectl port-forward -n open-feature-demo svc/open-feature-demo-service 30000
