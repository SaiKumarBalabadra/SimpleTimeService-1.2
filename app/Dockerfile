#first commit test

# ── Stage 1: build dependencies ──────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .

# Install into an isolated prefix so we can copy cleanly into the final stage.
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: lean runtime image ───────────────────────────────────────────────
FROM python:3.12-slim

# Create a non-root system user/group — required by the challenge spec.
RUN addgroup --system appgroup \
 && adduser  --system --ingroup appgroup --no-create-home appuser

WORKDIR /app

# Copy installed packages from the builder, then the application source.
COPY --from=builder /install /usr/local
COPY main.py .

# Drop privileges before starting the server.
USER appuser

EXPOSE 8080

# Use exec form so signals (SIGTERM) reach uvicorn directly.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]