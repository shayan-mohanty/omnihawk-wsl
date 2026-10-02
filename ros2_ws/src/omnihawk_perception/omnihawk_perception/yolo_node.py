"""ROS 2 Ultralytics object-detection node for OmniHawk WSL."""
import cv2
import rclpy
from rclpy.qos import qos_profile_sensor_data
from cv_bridge import CvBridge
from rclpy.node import Node
from sensor_msgs.msg import Image
from vision_msgs.msg import Detection2D, Detection2DArray, ObjectHypothesisWithPose
from ultralytics import YOLO
from omnihawk_perception.fps_meter import FPSMeter


def _set_hypothesis(hyp, class_id: str, score: float):
    if hasattr(hyp, "hypothesis"):
        hyp.hypothesis.class_id = class_id
        hyp.hypothesis.score = float(score)
    else:
        hyp.id = class_id
        hyp.score = float(score)


class YoloNode(Node):
    def __init__(self):
        super().__init__("yolo_node")
        self.declare_parameter("image_topic", "/camera")
        self.declare_parameter("model_path", "")
        self.declare_parameter("device", "cpu")
        self.declare_parameter("confidence_threshold", 0.4)
        self.declare_parameter("publish_annotated", True)

        image_topic = self.get_parameter("image_topic").value
        model_path = self.get_parameter("model_path").value
        self.confidence_threshold = float(self.get_parameter("confidence_threshold").value)
        self.publish_annotated = bool(self.get_parameter("publish_annotated").value)
        if not model_path:
            raise RuntimeError("model_path is required; provide a local YOLO .pt model")

        self.device = self.get_parameter("device").value
        self.model = YOLO(model_path, task="detect")
        self.bridge = CvBridge()
        self.fps_meter = FPSMeter()
        self.create_subscription(Image, image_topic, self.on_image, qos_profile_sensor_data)
        self.annotated_pub = self.create_publisher(Image, f"{image_topic}/annotated", 10)
        self.detections_pub = self.create_publisher(Detection2DArray, f"{image_topic}/detections", 10)

    def on_image(self, msg: Image):
        frame = self.bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")
        result = self.model.predict(frame, conf=self.confidence_threshold, verbose=False, device=self.device)[0]
        fps = self.fps_meter.tick()
        output = Detection2DArray()
        output.header = msg.header

        if result.boxes is not None:
            for box in result.boxes:
                cx, cy, width, height = box.xywh[0].tolist()
                cls_id = int(box.cls[0].item())
                score = float(box.conf[0].item())
                det = Detection2D()
                det.header = msg.header
                det.bbox.center.position.x = cx
                det.bbox.center.position.y = cy
                det.bbox.size_x = width
                det.bbox.size_y = height
                hyp = ObjectHypothesisWithPose()
                _set_hypothesis(hyp, result.names.get(cls_id, str(cls_id)), score)
                det.results.append(hyp)
                output.detections.append(det)
        self.detections_pub.publish(output)

        if self.publish_annotated:
            annotated = result.plot()
            cv2.putText(annotated, f"FPS: {fps:.1f} detections: {len(output.detections)}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2, cv2.LINE_AA)
            out = self.bridge.cv2_to_imgmsg(annotated, encoding="bgr8")
            out.header = msg.header
            self.annotated_pub.publish(out)


def main(args=None):
    rclpy.init(args=args)
    node = YoloNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
