serve:
	watchexec --ignore-nothing -o restart -w content gorush serve || true

build:
	gorush build
	docker build -t levinion/blog .

push: build
	${MAKE} git
	${MAKE} dockerhub

git:
	git add .
	git commit -m "update"
	git push origin main

dockerhub:
	docker push levinion/blog:latest

.PHONY: serve build push git dockerhub
