export AWS_PROFILE :=
export AWS_REGION  :=ap-southeast-2
export PROJECT_NAME :=ntkduy-2023
export ACCOUNT_ID :=390726816328
export SHORT_ENV :=dev
export TEMPLATE_PATH :=examples
export TF_PATH := iac/terraform/environments/dev/common
export BUCKET_NAME:=terraformdemo1231239

# Running list_ami_aws_default to get that information
export AWS_AMI_ID :=ami-0d9f286195031c3d9

# Docker Compose version v2.10.2
build_base:
	docker-compose -p laraveldemo -f docker-compose.yml build --no-cache base

# Codebuild is running version docker-compose v1
tag_base_ci:
	docker tag laraveldemo_base:latest laraveldemo-base:latest 
build_base_ci:
	make build_base
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


# Delete all objects in the s3 bucket.
# Delete all cloudwatch logs group.
# Delete all images in ECR repos.

destroy_infra_all:
	cd $(TF_PATH) && \
		terraform destroy
destroy_infra:
	cd $(TF_PATH) && \
		terraform apply \
			-var="vpc_created=false" -var="cloudfront_created=false" \
			-var="elb_created=false" -var="ecs_created=false" \
			-var="ecs_service_created=false" -var="codedeploy_created=false" \
			-var="codebuild_created=false" -var="codebuild_created=false" \
			-var="codepipeline_created=false" -var="cloudfront_created=false" \
			-var="db_created=false" -var="ec2_created=false"

create_infra:
	cd $(TF_PATH) && \
		terraform init && \
		terraform plan && \
		terraform apply

list_ami_aws_default:
	 aws ec2 describe-images \
	 	--filters 'Name=architecture,Values=x86_64' 'Name=virtualization-type,Values=hvm' 'Name=root-device-type,Values=ebs' 'Name=block-device-mapping.volume-type,Values=gp2' 'Name=ena-support,Values=true' 'Name=owner-alias,Values=amazon' 'Name=name,Values=*amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' \
	 	--query 'Images[*].[ImageId,Name,Description]' --output table

generate_settings:
	cat ${TEMPLATE_PATH}/buildspec_example.yml \
		| sed "s/SHORT_ENV/${SHORT_ENV}/; s/PROJECT_NAME/${PROJECT_NAME}/; s/ACCOUNT_ID/${ACCOUNT_ID}/; s/AWS_REGION/${AWS_REGION}/" \
		> "codebuild/buildspec.yml"

	cat ${TEMPLATE_PATH}/taskdef_template_example.json \
		| sed "s/SHORT_ENV/${SHORT_ENV}/; s/PROJECT_NAME/${PROJECT_NAME}/; s/ACCOUNT_ID/${ACCOUNT_ID}/; s/AWS_REGION/${AWS_REGION}/" \
		> "codedeploy/taskdef_template.json"


	cat ${TEMPLATE_PATH}/terraform_provider_example.tf \
		| sed "s/SHORT_ENV/${SHORT_ENV}/; s/PROJECT_NAME/${PROJECT_NAME}/; s/ACCOUNT_ID/${ACCOUNT_ID}/; s/AWS_REGION/${AWS_REGION}/" \
		| sed "s/BUCKET_NAME/${BUCKET_NAME}/; s/AWS_PROFILE/${AWS_PROFILE}/" \
		> "${TF_PATH}/provider.tf"

	cat ${TEMPLATE_PATH}/terraform_variables_example.tf \
		| sed "s/SHORT_ENV/${SHORT_ENV}/; s/PROJECT_NAME/${PROJECT_NAME}/; s/ACCOUNT_ID/${ACCOUNT_ID}/; s/AWS_REGION/${AWS_REGION}/" \
		| sed "s/BUCKET_NAME/${BUCKET_NAME}/; s/AWS_PROFILE/${AWS_PROFILE}/; s/AWS_AMI_ID/${AWS_AMI_ID}/" \
		> "${TF_PATH}/variables.tf"

	cat ${TEMPLATE_PATH}/ecs_example.tpl \
		| sed "s/SHORT_ENV/${SHORT_ENV}/; s/PROJECT_NAME/${PROJECT_NAME}/; s/ACCOUNT_ID/${ACCOUNT_ID}/; s/AWS_REGION/${AWS_REGION}/" \
		| sed "s/BUCKET_NAME/${BUCKET_NAME}/; s/AWS_PROFILE/${AWS_PROFILE}/" \
		> "${TF_PATH}/scripts/ecs.tpl"
