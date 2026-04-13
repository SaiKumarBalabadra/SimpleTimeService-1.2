"""
SimpleTimeService — returns the current UTC timestamp and the caller's IP.

Runs on port 8080 as a non-root user inside Docker / Kubernetes.
"""

from fastapi import FastAPI, Request
import datetime

app = FastAPI(title="SimpleTimeService")


@app.get("/")
async def root(request: Request) -> dict:
    # Respect X-Forwarded-For set by load-balancers / ingress controllers.
    forwarded_for = request.headers.get("X-Forwarded-For")
    ip = forwarded_for.split(",")[0].strip() if forwarded_for else request.client.host
    return {
        "timestamp": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "ip": ip,
    }


@app.get("/healthz")
async def healthz() -> dict:
    """Liveness probe — always 200 when the process is alive."""
    return {"status": "ok"}