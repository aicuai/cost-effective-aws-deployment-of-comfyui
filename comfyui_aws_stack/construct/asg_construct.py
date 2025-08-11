from aws_cdk import (
    aws_ecs as ecs,
    aws_ec2 as ec2,
    aws_iam as iam,
    aws_autoscaling as autoscaling,
    RemovalPolicy,
    Duration,
)
from constructs import Construct
from cdk_nag import NagSuppressions
from typing import Optional


class AsgConstruct(Construct):
    auto_scaling_group: autoscaling.AutoScalingGroup

    def __init__(
            self,
            scope: Construct,
            construct_id: str,
            vpc: ec2.Vpc,
            use_spot: bool,
            spot_price: str,
            auto_scale_down: bool,
            schedule_auto_scaling: bool,
            timezone: str,
            schedule_scale_down: str,
            schedule_scale_up: str,
            desired_capacity: Optional[int] = None,
            **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        self.desired_capacity = desired_capacity

        # Create Auto Scaling Group Security Group
        asg_security_group = ec2.SecurityGroup(
            scope,
            "AsgSecurityGroup",
            vpc=vpc,
            description="Security Group for ASG",
            allow_all_outbound=True,
        )

        # EC2 Role
        ec2_role = iam.Role(
            scope,
            "EC2Role",
            assumed_by=iam.ServicePrincipal("ec2.amazonaws.com"),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name(
                    "AmazonSSMManagedEC2InstanceDefaultPolicy"),
                iam.ManagedPolicy.from_aws_managed_policy_name(
                    "service-role/AmazonEC2ContainerServiceforEC2Role")
            ],
        )

        # UserData to mount instance store
        user_data = ec2.UserData.for_linux()
        user_data.add_commands(
            'set -e',
            # Find and mount the instance store volume
            # This script assumes the instance store is the second NVMe device
            'INSTANCE_STORE_DEVICE=$(find /dev -name "nvme?n?" | sort | sed -n "2p")',
            'if [ -n "$INSTANCE_STORE_DEVICE" ]; then',
            '  echo "Found instance store at ${INSTANCE_STORE_DEVICE}"',
            '  # Check if already formatted',
            '  if ! blkid -s TYPE -o value "${INSTANCE_STORE_DEVICE}"; then',
            '    echo "Formatting ${INSTANCE_STORE_DEVICE}"',
            '    mkfs.ext4 "${INSTANCE_STORE_DEVICE}"',
            '  fi',
            '  mkdir -p /data',
            '  mount "${INSTANCE_STORE_DEVICE}" /data',
            '  chmod -R 777 /data',
            '  # Add to fstab to remount on reboot (though data is lost)',
            '  if ! grep -q "${INSTANCE_STORE_DEVICE}" /etc/fstab; then',
            '    echo "${INSTANCE_STORE_DEVICE} /data ext4 defaults,nofail 0 2" >> /etc/fstab',
            '  fi',
            'else',
            '  echo "No instance store device found. Models and outputs will use the root EBS volume."',
            '  # Still create /data for consistent pathing',
            '  mkdir -p /data',
            '  chmod -R 777 /data',
            'fi'
        )

        # Create a Launch Template
        launchTemplate = ec2.LaunchTemplate(
            scope,
            "Host",
            instance_type=ec2.InstanceType("g5.2xlarge"),
            machine_image=ecs.EcsOptimizedImage.amazon_linux2(
                hardware_type=ecs.AmiHardwareType.GPU
            ),
            role=ec2_role,
            security_group=asg_security_group,
            block_devices=[
                ec2.BlockDevice(
                    device_name="/dev/xvda",
                    volume=ec2.BlockDeviceVolume.ebs(volume_size=30,
                                                     encrypted=True)
                )
            ],
            user_data=user_data,
        )

        # Create an Auto Scaling Group
        auto_scaling_group = autoscaling.AutoScalingGroup(
            scope,
            "ASG",
            vpc=vpc,
            launch_template=launchTemplate,
            min_capacity=1,
            max_capacity=1,
            desired_capacity=1,
            new_instances_protected_from_scale_in=False,
            max_instance_lifetime=Duration.days(7),
        )

        auto_scaling_group.apply_removal_policy(RemovalPolicy.DESTROY)

        # Nag Suppressions
        NagSuppressions.add_resource_suppressions(
            [asg_security_group],
            suppressions=[
                {"id": "AwsSolutions-EC23",
                 "reason": "The Security Group and ALB needs to allow 0.0.0.0/0 inbound access for the ALB to be publicly accessible. Additional security is provided via Cognito authentication."
                 },
                {"id": "AwsSolutions-ELB2",
                 "reason": "Adding access logs requires extra S3 bucket so removing it for sample purposes."},
            ],
            apply_to_children=True
        )

        NagSuppressions.add_resource_suppressions(
            [auto_scaling_group],
            suppressions=[
                {"id": "AwsSolutions-L1",
                 "reason": "Lambda Runtime is provided by custom resource provider and drain ecs hook implicitely and not critical for sample"
                 },
                {"id": "AwsSolutions-SNS2",
                 "reason": "SNS topic is implicitly created by LifeCycleActions and is not critical for sample purposes."
                 },
                {"id": "AwsSolutions-SNS3",
                 "reason": "SNS topic is implicitly created by LifeCycleActions and is not critical for sample purposes."
                 },
                {"id": "AwsSolutions-AS3",
                 "reason": "Not all notifications are critical for ComfyUI sample"
                 }
            ],
            apply_to_children=True
        )

        # Output
        self.auto_scaling_group = auto_scaling_group
