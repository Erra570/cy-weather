.PHONY: help install test test-unit test-integration test-performance test-coverage test-fast test-verbose clean lint format

help: ## Affiche cette aide
	@echo "Commandes disponibles pour CY Weather:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

install: ## Installe toutes les dépendances
	@echo "📦 Installation des dépendances..."
	pip install -r api/requirements.txt
	pip install -r test/requirements-test.txt
	@echo "✅ Installation terminée"

install-dev: install ## Installe les dépendances de développement
	@echo "📦 Installation des outils de développement..."
	pip install flake8 black isort pytest-watch
	@echo "✅ Installation dev terminée"

test: ## Exécute tous les tests
	@echo "🧪 Exécution de tous les tests..."
	pytest -v

test-unit: ## Exécute uniquement les tests unitaires
	@echo "🔬 Exécution des tests unitaires..."
	pytest -v -m unit

test-integration: ## Exécute uniquement les tests d'intégration
	@echo "🔗 Exécution des tests d'intégration..."
	pytest -v -m integration

test-performance: ## Exécute les tests de performance
	@echo "⚡ Exécution des tests de performance..."
	pytest -v -m slow test/test_performance.py

test-coverage: ## Exécute les tests avec couverture de code
	@echo "📊 Exécution des tests avec couverture..."
	pytest --cov=api/src --cov-report=term-missing --cov-report=html --cov-report=xml
	@echo ""
	@echo "📈 Rapport de couverture généré dans htmlcov/index.html"

test-fast: ## Exécute les tests rapides (sans les tests lents)
	@echo "⚡ Exécution des tests rapides..."
	pytest -v -m "not slow"

test-verbose: ## Exécute les tests en mode verbeux
	@echo "📢 Exécution en mode verbeux..."
	pytest -vv -s

test-watch: ## Exécute les tests en mode watch (nécessite pytest-watch)
	@echo "👀 Mode watch activé..."
	ptw -- -v

test-specific: ## Exécute un test spécifique (usage: make test-specific TEST=test_health_check)
	@echo "🎯 Exécution du test: $(TEST)"
	pytest -v -k "$(TEST)"

clean: ## Nettoie les fichiers générés
	@echo "🧹 Nettoyage..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -rf htmlcov/
	rm -f .coverage coverage.xml coverage.json
	@echo "✅ Nettoyage terminé"

lint: ## Vérifie le style du code avec flake8
	@echo "🔍 Vérification du style de code..."
	flake8 api/src test/ --max-line-length=127 --exclude=__pycache__

format: ## Formate le code avec black
	@echo "✨ Formatage du code..."
	black api/src test/
	isort api/src test/
	@echo "✅ Code formaté"

format-check: ## Vérifie si le code est bien formaté
	@echo "🔍 Vérification du formatage..."
	black --check api/src test/
	isort --check api/src test/

run-api: ## Démarre l'API en mode développement
	@echo "🚀 Démarrage de l'API..."
	cd api && uvicorn main:app --reload

run-api-prod: ## Démarre l'API en mode production
	@echo "🚀 Démarrage de l'API (production)..."
	cd api && uvicorn main:app --host 0.0.0.0 --port 8000

docker-up: ## Démarre tous les services Docker
	@echo "🐳 Démarrage des services Docker..."
	docker-compose up -d

docker-down: ## Arrête tous les services Docker
	@echo "🐳 Arrêt des services Docker..."
	docker-compose down

docker-logs: ## Affiche les logs Docker
	docker-compose logs -f

docker-test: ## Exécute les tests dans Docker
	@echo "🐳 Exécution des tests dans Docker..."
	docker-compose exec api pytest -v

coverage-report: ## Ouvre le rapport de couverture dans le navigateur
	@echo "📊 Ouverture du rapport de couverture..."
	@if [ -f htmlcov/index.html ]; then \
		if command -v xdg-open > /dev/null; then \
			xdg-open htmlcov/index.html; \
		elif command -v open > /dev/null; then \
			open htmlcov/index.html; \
		else \
			echo "❌ Impossible d'ouvrir le navigateur automatiquement"; \
			echo "📂 Le rapport est disponible dans: htmlcov/index.html"; \
		fi \
	else \
		echo "❌ Rapport de couverture introuvable"; \
		echo "💡 Exécutez 'make test-coverage' d'abord"; \
	fi

ci: lint test-coverage ## Exécute les vérifications CI (lint + tests + coverage)
	@echo "✅ Vérifications CI terminées"

all: clean install test-coverage ## Nettoie, installe et teste tout
	@echo "✅ Build complet terminé"
