deps:
	pip install -r requirements.txt

lint:
	flake8 . --exclude=venv,.venv,.circleci

.PHONY: deps lint