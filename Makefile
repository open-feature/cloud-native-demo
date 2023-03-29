cleanup-environment: uninstall-ofo uninstall-argo

install-environment: install-ofo install-argo

install-ofo:
	kubectl apply -f environment/ofo/ofo.yaml

uninstall-ofo:
	kubectl delete -f environment/ofo/ofo.yaml

install-argo:
	kubectl create namespace argocd
	kubectl -n argocd apply -f environment/argo/argo.yaml
	kubectl -n argocd apply -f environment/argo/app.yaml

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
	kubectl port-forward -n open-feature-demo svc/open-feature-demo-service 8085:80

port-forward-argo:
	@echo ""
	@echo "Open Argo in your Browser: http://localhost:8081"
	@echo "CTRL-c to stop port-forward"

	@echo ""
	kubectl port-forward -n argocd svc/argocd-server 8081:80
