#!/usr/bin/env python3
import os
import aws_cdk as cdk
from aws_cdk import Environment
from aws_cdk import Aspects
from comfyui_aws_stack.comfyui_aws_stack import ComfyUIStack
from cdk_nag import AwsSolutionsChecks, NagSuppressions

app = cdk.App()
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
    # Override Parameters (example)
    # オートスケールダウンの無効化
    auto_scale_down=False,
    # カスタムドメインの設定
    # host_name="comfyui",                        # サブドメイン部分
    # domain_name="aicu.jp",                      # メインドメイン
    # hosted_zone_id="Z03523711WHPFZJNX9T5Y",     # Route 53のホストゾーンID
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
