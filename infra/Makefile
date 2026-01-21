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
	terraform apply -var-file="Airbnb.tfvars" -auto-approve

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
	terraform destroy -var-file="Airbnb.tfvars" -auto-approve

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

deploy-all: nike airbnb mcdonalds
	@echo "--- ✅ Todos os clusters foram criados! ---"
	@echo "Para listar: minikube profile list"

destroy-all: destroy-nike destroy-airbnb destroy-mcdonalds
	@echo "--- 💥 Tudo destruído. O teu PC está leve novamente. ---"


CLIENTS_LIST = nike airbnb mcdonalds
ENVS_LIST = dev qa prod

update-hosts:
	@echo "--- 🔄 A atualizar /etc/hosts (precisa de sudo) ---"
	@# 1. Faz backup do ficheiro hosts atual por segurança
	@sudo cp /etc/hosts /etc/hosts.backup
	
	@# 2. Limpa linhas antigas criadas por este projeto (procura pela tag #TF-Project)
	@sudo sed -i '/#TF-Project/d' /etc/hosts

	@# 3. Loop para encontrar IPs e adicionar ao hosts
	@for client in $(CLIENTS_LIST); do \
		if minikube status -p "$$client-cluster" >/dev/null 2>&1; then \
			IP=$$(minikube ip -p "$$client-cluster"); \
			DOMAINS=""; \
			for env in $(ENVS_LIST); do \
				DOMAINS="$$DOMAINS odoo.$$env.$$client.local"; \
			done; \
			echo "A adicionar: $$IP -> $$DOMAINS"; \
			echo "$$IP $$DOMAINS #TF-Project" | sudo tee -a /etc/hosts >/dev/null; \
		else \
			echo "⚠️  Cluster $$client-cluster está desligado (ignorado)."; \
		fi \
	done
	@echo "--- ✅ /etc/hosts atualizado com sucesso! ---"

# --- TESTES DE CONEXÃO (CURL) ---

# Reutiliza as listas se já as definiste em cima, ou define aqui:
TEST_CLIENTS = nike airbnb mcdonalds
TEST_ENVS = dev qa prod

curl-test:
	@echo "--- 📡 A iniciar bateria de testes CURL ---"
	@for client in $(TEST_CLIENTS); do \
		echo "----------------------------------------"; \
		echo "🔍 Cliente: $$client"; \
		for env in $(TEST_ENVS); do \
			URL="https://odoo.$$env.$$client.local"; \
			\
			# Faz o Curl: \
			# -k: Ignora erro de certificado SSL \
			# -s: Modo silencioso (sem barra de progresso) \
			# -o /dev/null: Ignora o HTML da página \
			# -w: Mostra apenas o código HTTP (ex: 200, 308, 404) \
			# --connect-timeout 2: Desiste se demorar mais de 2s \
			STATUS=$$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 2 $$URL || echo "DOWN"); \
			\
			if [ "$$STATUS" = "DOWN" ]; then \
				echo "   ❌ [$$env] -> Falha de Conexão (Cluster desligado?)"; \
			elif [ "$$STATUS" = "200" ] || [ "$$STATUS" = "308" ]; then \
				echo "   ✅ [$$env] -> HTTP $$STATUS (Sucesso!)"; \
			else \
				echo "   ⚠️ [$$env] -> HTTP $$STATUS (Algo estranho...)"; \
			fi \
		done \
	done
	@echo "----------------------------------------"
	@echo "--- 🏁 Testes concluídos ---"