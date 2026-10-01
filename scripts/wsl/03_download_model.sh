#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
mkdir -p "$ROOT/models"
cd "$ROOT/models"
"$ROOT/.venv/bin/python" -c 'from ultralytics import YOLO; YOLO("yolov8n.pt")'
