CONTAINER_NAME=larmic-kotlin-native-starter-example
IMAGE_NAME=larmic/kotlin-native-starter-example
IMAGE_TAG=latest

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Build 🏗️———————————————————————————————————————————————————————————————————————————————————————————————————
build-binary: ## Builds binary (executable) in ./build/bin/app/releaseExecutable/app.(k)exe (used architecture of local machine)
	./gradlew linkReleaseExecutableApp

docker-build-arm: ## Builds arm docker image
	@echo "Remove docker image if already exists"
	docker rmi -f ${IMAGE_NAME}:${IMAGE_TAG}
	@echo "Build go docker image"
	DOCKER_BUILDKIT=1 docker buildx build --platform linux/arm64 -t ${IMAGE_NAME}:${IMAGE_TAG} --load .
	@echo "Prune intermediate images"
	docker image prune -f

docker-build-amd: ## Builds amd docker image
	@echo "Remove docker image if already exists"
	docker rmi -f ${IMAGE_NAME}:${IMAGE_TAG}
	@echo "Build go docker image"
	DOCKER_BUILDKIT=1 docker buildx build --platform linux/amd64 -t ${IMAGE_NAME}:${IMAGE_TAG} --load .
	@echo "Prune intermediate images"
	docker image prune -f

## —— Run application 🏃🏽————————————————————————————————————————————————————————————————————————————————————————
gradle-run: ## Runs app without any container
	./gradlew runDebug

docker-run: ## Runs docker container and uses configured env variable ${EXTERNAL_URL}
	@echo "Run docker container"
	docker run -d -p 8080:8080 --rm --name ${CONTAINER_NAME} ${IMAGE_NAME}:${IMAGE_TAG}
	docker logs -f ${CONTAINER_NAME}

docker-stop: ## Stops running docker container
	@echo "Stop docker container"
	docker stop ${CONTAINER_NAME}