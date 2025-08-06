from aws_cdk import (
    aws_ec2 as ec2,
    aws_efs as efs,
    RemovalPolicy,
)
from constructs import Construct
from cdk_nag import NagSuppressions

class EfsConstruct(Construct):

    def __init__(
            self,
            scope: Construct,
            construct_id: str,
            vpc: ec2.Vpc,
            **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # EFS File System
        self.file_system = efs.FileSystem(
            self, "EfsFileSystem",
            vpc=vpc,
            encrypted=True,
            lifecycle_policy=efs.LifecyclePolicy.AFTER_14_DAYS,  # Example: move to IA after 14 days
            performance_mode=efs.PerformanceMode.GENERAL_PURPOSE,
            throughput_mode=efs.ThroughputMode.BURSTING,
            removal_policy=RemovalPolicy.DESTROY # Change to RETAIN for production
        )

        # EFS Security Group
        efs_security_group = ec2.SecurityGroup(
            self, "EfsSecurityGroup",
            vpc=vpc,
            description="Security group for EFS",
            allow_all_outbound=True
        )
        
        # The security group will be connected from the ECS construct.
        pass

        # EFS Access Point
        self.access_point = self.file_system.add_access_point(
            "EfsAccessPoint",
            path="/comfyui",
            create_acl=efs.Acl(owner_uid="1000", owner_gid="1000", permissions="755"),
            posix_user=efs.PosixUser(uid="1000", gid="1000")
        )

        # Nag Suppressions
        NagSuppressions.add_resource_suppressions(
            [self.file_system],
            suppressions=[
                {"id": "AwsSolutions-EFS3",
                 "reason": "This is a sample project and does not require backup."
                 },
            ],
            apply_to_children=True
        )
