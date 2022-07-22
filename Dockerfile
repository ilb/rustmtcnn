# Rust as the base image
FROM rust:1.62
ARG DEBUG
# if --build-arg DEBUG=1, set TARGET to 'debug' or set to null otherwise.
ENV TARGET=${DEBUG:+debug}
# if TARGET is null, set it to 'release' (or leave as is otherwise).
ENV TARGET=${TARGET:-release}

# if --build-arg DEBUG=1, set PROFILE to 'dev' or set to null otherwise.
ENV PROFILE=${DEBUG:+dev}
# if PROFILE is null, set it to 'release' (or leave as is otherwise).
ENV PROFILE=${PROFILE:-release}

RUN echo "TARGET=$TARGET PROFILE=$PROFILE"

COPY ./build ./build

RUN build/dependencies.sh

# 1. Create a new empty shell project
RUN USER=root cargo new --bin rustmtcnn
WORKDIR /rustmtcnn

# 2. Copy our manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# 3. Build only the dependencies to cache them
#RUN cargo build --profile $PROFILE
RUN env RUST_BACKTRACE=full cargo build -vv --profile $PROFILE
RUN rm src/*.rs

# 4. Now that the dependency is built, copy your source code
COPY ./src ./src

# 5. Build for release.
RUN rm ./target/${TARGET}/deps/rustmtcnn*
RUN env RUST_BACKTRACE=full cargo build -vv --profile $PROFILE

RUN find . -type f -name libtensorflow.so.2 -exec cp -v {} /usr/lib \; \
    && find . -type f -name libtensorflow_framework.so.2 -exec cp -v {} /usr/lib \;

RUN cp -v "./target/$TARGET/rustmtcnn" /usr/local/bin

RUN if [ "$TARGET" = "debug" ] ; then apt-get install -y gdb; fi
RUN apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./rustfest.jpg /tmp/rustfest.jpg

CMD [ "/usr/local/bin/rustmtcnn", "/tmp/rustfest.jpg", "/tmp/test.jpg"]

