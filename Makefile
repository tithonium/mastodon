rebase:
	git fetch origin
	git rebase -i `git tag | grep -vE -- '-(beta|rc)' | semantic-sort -latest`

image:
	DOCKER_BUILDKIT=1 docker build -f ./Dockerfile -t ghcr.io/tithonium/mastodon:latest .
	DOCKER_BUILDKIT=1 docker build -f ./streaming/Dockerfile -t ghcr.io/tithonium/mastodon-streaming:latest .

tag:
	docker tag ghcr.io/tithonium/mastodon:clacks ghcr.io/tithonium/mastodon:previous
	docker tag ghcr.io/tithonium/mastodon-streaming:clacks ghcr.io/tithonium/mastodon-streaming:previous
	docker tag ghcr.io/tithonium/mastodon:latest ghcr.io/tithonium/mastodon:clacks
	docker tag ghcr.io/tithonium/mastodon-streaming:latest ghcr.io/tithonium/mastodon-streaming:clacks

rollback:
	docker tag ghcr.io/tithonium/mastodon:previous ghcr.io/tithonium/mastodon:clacks
	docker tag ghcr.io/tithonium/mastodon-streaming:previous ghcr.io/tithonium/mastodon-streaming:clacks

push:
	docker push ghcr.io/tithonium/mastodon:clacks
	docker push ghcr.io/tithonium/mastodon-streaming:clacks

rebuild: image tag push

restart:
	docker service update --with-registry-auth --update-order=stop-first --update-parallelism=1 --image=ghcr.io/tithonium/mastodon:clacks --force clacks_sidekiq
	docker service update --with-registry-auth --update-order=start-first --update-parallelism=1 --image=ghcr.io/tithonium/mastodon-streaming:clacks --force clacks_streaming
	docker service update --with-registry-auth --update-order=start-first --update-parallelism=1 --image=ghcr.io/tithonium/mastodon:clacks --force clacks_web

