"""
DEPRECATED: This bridge is no longer needed with OrbStack.

OrbStack (like Docker Desktop) exposes 0.0.0.0-bound container ports on all
host interfaces, so VirtualBox VMs can reach services at 192.168.56.1 directly.

This bridge was required for Finch/Lima, which only exposed ports on 127.0.0.1.
Kept for reference only.
"""

import argparse
import asyncio
import logging
import signal
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="[%(asctime)s] BRIDGE %(levelname)s: %(message)s", datefmt="%H:%M:%S"
)
logger = logging.getLogger(__name__)

PORTS = [3142, 5050, 5001, 5002, 5003, 5004, 6443, 8404]
BIND_Host = "0.0.0.0"  # Listen on all interfaces (catches traffic to 192.168.56.1)
TARGET_HOST = "127.0.0.1"  # Where containers export the ports (was Finch-specific)


async def pipe(reader, writer):
    try:
        while not reader.at_eof():
            data = await reader.read(2048)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except Exception as e:
        # Connection resets are common, don't spam logs
        pass
    finally:
        writer.close()


async def handle_client(local_reader, local_writer, port):
    peer = local_writer.get_extra_info("peername")
    # logger.debug(f"Connection from {peer} on port {port}")

    try:
        remote_reader, remote_writer = await asyncio.open_connection(TARGET_HOST, port)

        pipe1 = asyncio.create_task(pipe(local_reader, remote_writer))
        pipe2 = asyncio.create_task(pipe(remote_reader, local_writer))

        await asyncio.gather(pipe1, pipe2)
    except Exception as e:
        logger.error(f"Failed to bridge port {port}: {e}")
    finally:
        local_writer.close()


async def start_server(port):
    server = await asyncio.start_server(lambda r, w: handle_client(r, w, port), BIND_Host, port)
    logger.info(f"Bridging {BIND_Host}:{port} -> {TARGET_HOST}:{port}")
    async with server:
        await server.serve_forever()


async def main():
    logger.info("Starting Cache Bridge Service...")

    tasks = []
    for port in PORTS:
        tasks.append(asyncio.create_task(start_server(port)))

    # Handle shutdown signals
    stop_event = asyncio.Event()
    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, lambda: stop_event.set())

    try:
        await asyncio.gather(*tasks)
    except asyncio.CancelledError:
        pass


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
