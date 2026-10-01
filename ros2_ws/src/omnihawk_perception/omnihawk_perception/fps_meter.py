"""Rolling-window FPS counter for the perception node."""
import time
from collections import deque


class FPSMeter:
    def __init__(self, window: int = 30):
        self._timestamps = deque(maxlen=window)

    def tick(self) -> float:
        now = time.monotonic()
        self._timestamps.append(now)
        if len(self._timestamps) < 2:
            return 0.0
        elapsed = self._timestamps[-1] - self._timestamps[0]
        return 0.0 if elapsed <= 0 else (len(self._timestamps) - 1) / elapsed
