#!/usr/bin/env python3
import os
import aws_cdk as cdk
from aws_cdk import Environment
from aws_cdk import Aspects
from comfyui_aws_stack.comfyui_aws_stack import ComfyUIStack
from cdk_nag import AwsSolutionsChecks, NagSuppressions

app = cdk.App()

# Get context variables
user_pool_id = app.node.try_get_context("user_pool_id")
user_pool_client_id = app.node.try_get_context("user_pool_client_id")
user_pool_domain_name = app.node.try_get_context("user_pool_domain_name")
domain_name = app.node.try_get_context("domain_name")
host_name = app.node.try_get_context("host_name")
slack_webhook_url = app.node.try_get_context("slack_webhook_url")

comfy_ui_stack = ComfyUIStack(
    app, "ComfyUIStack",
    description="ComfyUI on AWS (uksb-ggn3251wsp)",
    env=Environment(
        account=os.environ["CDK_DEFAULT_ACCOUNT"],
        region=os.environ["CDK_DEFAULT_REGION"]
    ),
    tags={
        "Repository": "aws-samples/cost-effective-aws-deployment-of-comfyui"
    },
    user_pool_id=user_pool_id,
    user_pool_client_id=user_pool_client_id,
    user_pool_domain_name=user_pool_domain_name,
    domain_name=domain_name,
    host_name=host_name,
    slack_webhook_url=slack_webhook_url,
    # Override Parameters (example)
    # auto_scale_down=False,
    # schedule_auto_scaling=True,
    # timezone="Asia/Tokyo",
    # schedule_scale_up="0 8 * * 1-5",
    # schedule_scale_down="0 19 * * *",
    # self_sign_up_enabled=True,
    # allowed_sign_up_email_domains=["amazon.com"],
)

Aspects.of(app).add(AwsSolutionsChecks(verbose=False))
NagSuppressions.add_stack_suppressions(stack=comfy_ui_stack, suppressions=[
    {"id": "AwsSolutions-L1", "reason": "Lambda Runtime is provided by custom resource provider and drain ecs hook implicitely and not critical for sample"},
    {"id": "AwsSolutions-IAM4",
        "reason": "For sample purposes the managed policy is sufficient"},
    {"id": "AwsSolutions-IAM5",
        "reason": "Some rules require '*' wildcard as an example ACM operations, and other are sufficient for Sample"},
    {"id": "CdkNagValidationFailure", "reason": "Suppressions for cdk nag"},
])

app.synth()
