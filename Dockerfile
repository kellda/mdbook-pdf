FROM rust as builder
COPY . .
RUN apt update && apt install -y build-essential
# Install mdbook
RUN cargo install --git https://github.com/HollowMan6/mdBook mdbook
RUN cargo install --path .

FROM python as base
RUN apt-get update \
    && apt-get install -y \
        chromium \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /root/.cache \
    && mkdir /mdbook-pdf
COPY . /mdbook-pdf
RUN pip3 install --no-cache-dir /mdbook-pdf \
    && rm -rf /mdbook-pdf
COPY --from=builder /usr/local/cargo/bin/mdbook-pdf /usr/local/bin/mdbook-pdf
COPY --from=builder /usr/local/cargo/bin/mdbook /usr/local/bin/mdbook
WORKDIR /book
ENTRYPOINT [ "mdbook", "build" ]
