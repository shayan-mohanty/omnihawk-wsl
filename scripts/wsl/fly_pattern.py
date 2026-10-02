#!/usr/bin/env python3
"""Square-flight smoke test for PX4 SITL only."""
import argparse
import asyncio
from mavsdk import System
from mavsdk.offboard import OffboardError, VelocityNedYaw

async def ready(stream, predicate):
    async for value in stream:
        if predicate(value):
            return
    raise RuntimeError("Telemetry stream ended")

async def main():
    drone = System()
    await drone.connect(system_address="udpin://0.0.0.0:14540")
    await asyncio.wait_for(ready(drone.core.connection_state(), lambda s: s.is_connected), 30)
    await asyncio.wait_for(ready(drone.telemetry.health(),
        lambda h: h.is_global_position_ok and h.is_home_position_ok), 60)
    armed = False
    offboard = False
    try:
        await drone.action.set_takeoff_altitude(3.0)
        await drone.action.arm()
        armed = True
        await drone.action.takeoff()
        await asyncio.wait_for(ready(drone.telemetry.position(),
            lambda p: p.relative_altitude_m >= 2.5), 30)
        await drone.offboard.set_velocity_ned(VelocityNedYaw(0, 0, 0, 0))
        await drone.offboard.start()
        offboard = True
        for north, east, yaw in [(1.5, 0, 0), (0, 1.5, 90), (-1.5, 0, 180), (0, -1.5, 270)]:
            await drone.offboard.set_velocity_ned(VelocityNedYaw(north, east, 0, yaw))
            await asyncio.sleep(4)
        await drone.offboard.set_velocity_ned(VelocityNedYaw(0, 0, 0, 0))
        await asyncio.sleep(2)
    finally:
        if offboard:
            try:
                await asyncio.wait_for(drone.offboard.stop(), 10)
            except (OffboardError, asyncio.TimeoutError):
                pass
        if armed:
            await asyncio.wait_for(drone.action.land(), 10)
            await asyncio.wait_for(ready(drone.telemetry.in_air(), lambda airborne: not airborne), 60)
            print("Landed")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sitl", action="store_true", required=True,
                        help="Confirm only PX4 simulation is connected")
    parser.parse_args()
    asyncio.run(main())
