# .PHONY diz ao Make que isto não são ficheiros, são comandos
.PHONY: init nike airbnb mcdonalds clean destroy-all

# Inicializa o Terraform (faz o download dos providers)
init:
	terraform init

# --- CLIENTE NIKE ---
nike:
	@echo "--- 👟 A preparar ambiente NIKE ---"
	# Tenta selecionar o workspace 'nike', se não existir, cria-o
	terraform workspace select nike || terraform workspace new nike
	terraform init
	# Aplica a configuração usando as variáveis da Nike
	terraform apply -var-file="nike.tfvars" -auto-approve

# --- CLIENTE AIRBNB ---
airbnb:
	@echo "--- 🏠 A preparar ambiente AIRBNB ---"
	terraform workspace select airbnb || terraform workspace new airbnb
	terraform init
	terraform apply -var-file="airbnb.tfvars" -auto-approve

# --- CLIENTE MCDONALDS ---
mcdonalds:
	@echo "--- 🍔 A preparar ambiente MCDONALDS ---"
	terraform workspace select mcdonalds || terraform workspace new mcdonalds
	terraform init
	terraform apply -var-file="mcdonalds.tfvars" -auto-approve

# --- DESTRUIR TUDO (Cuidado!) ---
destroy-nike:
	terraform workspace select nike
	terraform destroy -var-file="nike.tfvars" -auto-approve

destroy-airbnb:
	terraform workspace select airbnb
	terraform destroy -var-file="airbnb.tfvars" -auto-approve

# --- LIMPEZA TOTAL ---
clean:
	@echo "--- 🧹 A limpar tudo... ---"
	# Remove ficheiros de estado locais e backups
	rm -rf terraform.tfstate*
	rm -rf .terraform/
	rm -rf .terraform.lock.hcl
	# Apaga todos os clusters minikube de uma vez
	minikube delete --all
	@echo "--- ✨ Limpeza concluída ---"

deploy-all: init nike airbnb mcdonalds
	@echo "--- ✅ Todos os clusters foram criados! ---"
	@echo "Para listar: minikube profile list"

destroy-all: destroy-nike destroy-airbnb destroy-mcdonalds
	@echo "--- 💥 Tudo destruído. O teu PC está leve novamente. ---"


CLIENTS_LIST = nike airbnb mcdonalds

ENVS_airbnb   = dev prod
ENVS_mcdonalds = dev qa beta prod
ENVS_nike     = dev qa prod
update-hosts:
	@echo "--- 🔄 A atualizar /etc/hosts ---"

	@sed '/#TF-Project/d' /etc/hosts > /tmp/hosts.tmp
	@cat /tmp/hosts.tmp > /etc/hosts
	@rm /tmp/hosts.tmp

	@for client in $(CLIENTS_LIST); do \
		case "$$client" in \
			airbnb)    ENVS="dev prod" ;; \
			mcdonalds) ENVS="dev qa beta prod" ;; \
			nike)      ENVS="dev qa prod" ;; \
		esac; \
		if minikube status -p "$$client-cluster" >/dev/null 2>&1; then \
			IP=$$(minikube ip -p "$$client-cluster"); \
			DOMAINS=""; \
			for env in $$ENVS; do \
				DOMAINS="$$DOMAINS odoo.$$env.$$client.local"; \
			done; \
			echo "A adicionar: $$IP -> $$DOMAINS"; \
			echo "$$IP $$DOMAINS #TF-Project" >> /etc/hosts; \
		else \
			echo "⚠️  Cluster $$client-cluster está desligado (ignorado)."; \
		fi; \
	done

	@echo "--- ✅ /etc/hosts atualizado com sucesso! ---"

curl-test:
	@echo "--- 📡 A iniciar bateria de testes CURL ---"
	@for client in $(CLIENTS_LIST); do \
		case "$$client" in \
			airbnb)    ENVS="dev prod" ;; \
			mcdonalds) ENVS="dev qa beta prod" ;; \
			nike)      ENVS="dev qa prod" ;; \
		esac; \
		echo "----------------------------------------"; \
		echo "🔍 Cliente: $$client"; \
		for env in $$ENVS; do \
			URL="https://odoo.$$env.$$client.local"; \
			STATUS=$$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 2 $$URL || echo "DOWN"); \
			if [ "$$STATUS" = "DOWN" ]; then \
				echo "   ❌ [$$env] -> Falha de Conexão (Cluster desligado?)"; \
			elif [ "$$STATUS" = "303" ] || [ "$$STATUS" = "308" ]; then \
				echo "   ✅ [$$env] -> HTTPS $$STATUS (Sucesso!)"; \
			else \
				echo "   ⚠️ [$$env] -> HTTPS $$STATUS (Algo estranho...)"; \
			fi; \
		done; \
	done
	@echo "----------------------------------------"
	@echo "--- 🏁 Testes concluídos ---"


test: update-hosts curl-test