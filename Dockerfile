FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update; apt install -y sudo wget lsb-release lsb-release wget \
          software-properties-common gnupg curl build-essential make python3 python3-dev python-is-python3 \
          clang ninja-build git ca-certificates gpg cmake

# install llvm
RUN cd /tmp; \
          wget https://apt.llvm.org/llvm.sh; \
          chmod +x llvm.sh; \
          sudo ./llvm.sh 20

# install uv and conan
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv tool install conan

# add remotes
ARG LAGOON_PWD
RUN uvx conan remote add lagoon http://lagoon:9300/ --force; \
          uvx conan remote login lagoon ci -p ${LAGOON_PWD}

# clone repo
RUN git clone https://github.com/mattyoung101/conan-center-index.git; \
    cd conan-center-index; \
    git checkout slang

# install profiles
COPY . /build
RUN cd /build && uvx conan config install .
RUN uvx conan profile show

# build slang
RUN cd conan-center-index/recipes/slang; \
    CC=clang-20 CXX=clang++-20 uvx conan create all/conanfile.py --version=9.1 --build=missing --profile=debug

# upload results
RUN uvx conan upload -v -r lagoon "*" --confirm
