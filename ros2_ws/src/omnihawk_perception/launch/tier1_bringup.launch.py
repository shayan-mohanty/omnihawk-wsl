"""Bridge a discovered Gazebo camera topic and run YOLO."""
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration as LC
from launch_ros.actions import Node
from launch_ros.parameter_descriptions import ParameterValue

def generate_launch_description():
    gz_topic = LC("gz_camera_topic")
    return LaunchDescription([
        DeclareLaunchArgument("gz_camera_topic"),
        DeclareLaunchArgument("model_path"),
        DeclareLaunchArgument("device", default_value="cpu"),
        DeclareLaunchArgument("confidence_threshold", default_value="0.4"),
        DeclareLaunchArgument("publish_annotated", default_value="true"),
        Node(package="ros_gz_bridge", executable="parameter_bridge",
             arguments=[[gz_topic, "@sensor_msgs/msg/Image[gz.msgs.Image"]],
             remappings=[(gz_topic, "/camera")],
             parameters=[{"qos_overrides./camera.publisher.reliability": "best_effort"}]),
        Node(package="omnihawk_perception", executable="yolo_node", output="screen",
             parameters=[{
                 "image_topic": "/camera",
                 "model_path": ParameterValue(LC("model_path"), value_type=str),
                 "device": ParameterValue(LC("device"), value_type=str),
                 "confidence_threshold": ParameterValue(LC("confidence_threshold"), value_type=float),
                 "publish_annotated": ParameterValue(LC("publish_annotated"), value_type=bool),
             }]),
    ])
