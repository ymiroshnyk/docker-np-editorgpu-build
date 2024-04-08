FROM ubuntu:20.04

MAINTAINER Yuriy Miroshnyk <y.miroshnyk@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt update && apt install -y \
	software-properties-common \
	build-essential

# gcc-10
RUN apt update && apt install -y \
	gcc-10 \
	g++-10
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 800 --slave /usr/bin/g++ g++ /usr/bin/g++-10

# cmake
RUN apt update && apt install -y \
	git \
	lsb-release \
	wget \
	apt-transport-https
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
RUN apt update && apt install -y cmake

# Pip
RUN apt update && apt install -y \
	python3-pip \
	python3-wheel
	
# conan
RUN pip3 install conan

# linuxdeployqt (requires --priviledged flag to run docker container)
RUN apt update && apt install -y \
	libfuse2
ADD https://github.com/probonopd/linuxdeployqt/releases/download/10/linuxdeployqt-continuous-x86_64.AppImage /opt/linuxdeployqt
RUN chmod +x /opt/linuxdeployqt

# ccache
ADD https://github.com/ccache/ccache/releases/download/v4.9.1/ccache-4.9.1.tar.gz /opt/
RUN cd /opt && tar -xzf ./ccache-4.9.1.tar.gz && cd ccache-4.9.1 && mkdir build && cd build && cmake .. && cmake --build . -j$(nproc) && make install && cp /usr/local/bin/ccache /usr/bin/ccache && cd ../.. && rm -rf ./ccache-4.9.1
ENV CCACHE_COMPILERCHECK=content \
	CCACHE_SLOPPINESS=pch_defines,time_macros \
	CCACHE_DIR=/ccache
	
# Google Breakpad
RUN apt update && apt install -y \
	libz-dev
RUN cd /opt && git clone https://chromium.googlesource.com/breakpad/breakpad \
	&& cd breakpad && git clone https://chromium.googlesource.com/linux-syscall-support src/third_party/lss \
	&& ./configure && make -j$(nproc)
ENV GOOGLE_BREAKPAD_PATH=/opt/breakpad

# clang
RUN apt update && apt install -y \
	clang
	
# Emscripten
RUN git clone https://github.com/emscripten-core/emsdk.git && cd emsdk && ./emsdk install latest && ./emsdk activate latest && echo "source /emsdk/emsdk_env.sh" >> /root/.bashrc
RUN apt update && apt install -y \
	ninja-build

# BEGIN X-SERVER IN DOCKER CONTAINER --------------------------------
# Setup mesa drivers
RUN add-apt-repository ppa:kisak/kisak-mesa
RUN apt update && apt install -y \
	libgl1-mesa-dev \
 	libglu1-mesa-dev \
	libfreetype6-dev \
	mesa-utils \
	xdotool \
	mesa-common-dev \
	libglib2.0-0

# Setup xvfb
RUN DEBIAN_FRONTEND=noninteractive \
  apt install -y \
  xvfb \
  x11-xkb-utils \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-scalable \
  xfonts-cyrillic \
  xorg \
  openbox \
  xserver-xorg-core

# Setup our environment variables.
ENV XVFB_WHD="1920x1080x24"\
  DISPLAY=":99" \
  LIBGL_DEBUG="verbose" \
  LIBGL_ALWAYS_SOFTWARE="1" \
  MESA_DEBUG="1" \
  GALLIUM_DRIVER="llvmpipe" \
  LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
  LP_NO_RAST="false" \
  LP_DEBUG="" \
  LP_PERF="" \
  LP_NUM_THREADS=""

# Copy our entrypoint into the container.
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set the default command.
ENTRYPOINT ["/entrypoint.sh"]

# END X-SERVER IN DOCKER CONTAINER --------------------------------

# Sources requirements
RUN apt update && apt install -y \
	libfontenc-dev libxaw7-dev libxcomposite-dev libxkbfile-dev libxmu-dev libxmuu-dev libxpm-dev libxres-dev libxtst-dev libxcb-render-util0-dev libxcb-xkb-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-xinerama0-dev uuid-dev libxcb-cursor-dev libxcb-composite0-dev libxcb-ewmh-dev libxcb-res0-dev libxcb-util-dev libxcb-util0-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-glx0-dev libxcb-present-dev libxcb-sync-dev libxcb-randr0-dev libxdamage-dev libx11-xcb-dev

RUN apt update && apt install -y \
	libxcursor-dev libxinerama-dev libxrandr-dev libxrender-dev libxss-dev libxv-dev libxxf86vm-dev pkg-config


