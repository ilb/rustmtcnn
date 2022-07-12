# Rust as the base image
FROM rust:1.59

# 1. Create a new empty shell project
RUN USER=root cargo new --bin mtcnn
WORKDIR /mtcnn

# 2. Copy our manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# 3. Build only the dependencies to cache them
RUN cargo build --release
RUN rm src/*.rs

# 4. Now that the dependency is built, copy your source code
COPY ./src ./src

# 5. Build for release.
RUN rm ./target/release/deps/mtcnn*
RUN cargo build --release
RUN find . -type f -name libtensorflow.so.2 -exec cp -v {} /usr/lib \; \
    && find . -type f -name libtensorflow_framework.so.2 -exec cp -v {} /usr/lib \;

COPY ./rustfest.jpg /tmp/rustfest.jpg

CMD ["./target/release/mtcnn", "/tmp/rustfest.jpg", "/tmp/test.jpg"]

#RUN cargo install --path .

#CMD ["mtcnn"]
