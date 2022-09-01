FROM debian:9.6 AS cargo-lede-sdk

LABEL IMAGE_NAME="maron/cargo-lede-sdk"

RUN set -ex; \
    apt-get update; apt-get install -y \
        build-essential \
        git \
        curl \
    ; \
    rm -rf /var/lib/apt/* /var/cache/apt/*

ENV USER build

ARG D_UID=1000
ARG D_GID=$D_UID
RUN set -ex; \
    addgroup --gid=$D_GID $USER; \
    adduser --system --uid=$D_UID --gid=$D_GID $USER

WORKDIR /home/$USER
USER $USER

ENV PATH="/home/$USER/.cargo/bin:${PATH}"
RUN bash -c "curl --proto '=https' --tlsv1.2 -sSf 'https://sh.rustup.rs' | sh /dev/stdin -y"

ARG RUST_VER=1.60.0
RUN set -ex; \
    rustup toolchain install $RUST_VER; \
    rustup component add rustfmt; \
    rustup target add arm-unknown-linux-musleabi --toolchain $RUST_VER; \
    rustup target add aarch64-unknown-linux-musl --toolchain $RUST_VER; \
    rustup default $RUST_VER

run curl https://downloads.openwrt.org/releases/17.01.6/targets/zynq/generic/lede-sdk-17.01.6-zynq_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64.tar.xz -o /tmp/lede-sdk.tar.xz
#RUN chown $USER /tmp/lede-sdk-17.01.6-zynq_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64.tar.xz

RUN mkdir "/home/$USER/sdk/"
RUN cd "/home/$USER/sdk/"
RUN tar -xf /tmp/lede-sdk.tar.xz -C "/home/$USER/sdk/"
ENV PATH="/home/$USER/sdk/lede-sdk-17.01.6-zynq_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64/staging_dir/toolchain-arm_cortex-a9+neon_gcc-5.4.0_musl-1.1.16_eabi/bin:${PATH}"
# RUN ls -l /home/$USER/sdk/lede-sdk-17.01.6-zynq_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64/staging_dir/toolchain-arm_cortex-a9+neon_gcc-5.4.0_musl-1.1.16_eabi/bin

ENV TOOLCHAIN="$HOME/sdk/lede-sdk-17.01.6-zynq_gcc-5.4.0_musl-1.1.16_eabi.Linux-x86_64/staging_dir/toolchain-arm_cortex-a9+neon_gcc-5.4.0_musl-1.1.16_eabi"
ENV CROSS_COMPILE=arm-openwrt-linux
