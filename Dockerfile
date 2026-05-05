FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/home/pyadm/.venv

RUN useradd --create-home --shell /bin/sh pyadm

# Install dependencies before copying source so this layer is cached
COPY pyproject.toml uv.lock LICENSE README.md ./
RUN uv sync --frozen --no-dev --no-install-project

COPY src/ ./src/
RUN uv sync --frozen --no-dev --no-editable


FROM python:3.13-slim-bookworm

RUN useradd --create-home --shell /bin/sh pyadm

COPY --from=builder --chown=pyadm:pyadm /home/pyadm/.venv /home/pyadm/.venv

ENV PATH="/home/pyadm/.venv/bin:$PATH"

USER pyadm
WORKDIR /home/pyadm

# Mount pyadm.conf here: -v ~/.config/pyadm:/home/pyadm/.config/pyadm:ro
VOLUME ["/home/pyadm/.config/pyadm"]

ENTRYPOINT ["pyadm"]
