# Docker Compose version v2.10.2
build_base:
	docker-compose -p laraveldemo -f docker-compose.yml build --no-cache base

tag_base_ci:
	docker tag laraveldemo_base:latest laraveldemo-base:latest 
build_base_ci:
	make make_build_base
	make tag_base_ci
	
build_php:
	docker-compose -p laraveldemo -f docker-compose.yml build php

build_nginx:
	docker-compose -p laraveldemo -f docker-compose.yml build nginx

log_php:
	docker-compose -p laraveldemo -f docker-compose.yml logs -f php

access_php:
	docker-compose -p laraveldemo -f docker-compose.yml exec php bash

log_nginx:
	docker-compose -p laraveldemo -f docker-compose.yml logs -f nginx

show_all:
	docker-compose -p laraveldemo -f docker-compose.yml ps

up:
	docker-compose -p laraveldemo -f docker-compose.yml up -d php nginx phpmyadmin

down:
	docker-compose -p laraveldemo -f docker-compose.yml down
