deps:
	pip install -r requirements.txt

lint:
	flake8 . --exclude=venv,.venv,.circleci

docker_build:
	docker build -t pawelwolf/ventis2db:latest .

docker_push:
	@echo "$$DOCKER_PASSWORD" | docker login --username "$$DOCKER_USERNAME" --password-stdin
	docker tag pawelwolf/ventis2db:latest pawelwolf/ventis2db:v3
	docker push pawelwolf/ventis2db:latest
	docker push pawelwolf/ventis2db:v3
	docker logout

.PHONY: deps lint docker_build docker_push