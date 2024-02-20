# [Choice] Debian / Ubuntu version (use Debian 12, Debian 11, Ubuntu 22.04 on local arm64/Apple Silicon): debian-12, debian-11, debian-10, ubuntu-22.04, ubuntu-20.04
ARG VARIANT=20.04
FROM ubuntu:${VARIANT}
USER root
LABEL maintainer="Chen Shun <e-shun.chen@geely.com>"
# Install needed packages. Use a separate RUN statement to add your own dependencies.
RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y libglm-dev build-essential autoconf openssh-server vim git libczmq-dev valgrind cgdb libpcap-dev net-tools iproute2 gitg meld libproj-dev ttf-wqy-microhei python3-pip gdb clang-format-6.0 libspatialindex-dev iputils-ping software-properties-common expect libgoogle-glog-dev x11-xserver-utils libopencv-dev cmake cppcheck clang lldb llvm tar curl zip unzip pkg-config bash-completion ninja-build zsh libopencv-dev graphviz xvfb mesa-utils llvm-7-dev bison flex python3-numpy libgl1-mesa-dev mesa-common-dev libglu1-mesa-dev\
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
RUN chsh -s /bin/zsh root

# Setting for enable ssh, avoiding confilcts with HERMES which using 22:2222
RUN sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^Port 22$/Port 2201/g' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && echo 'root:000000' |chpasswd

# Set local and time zone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=Asia/Shanghai

# Install zsh
RUN curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install.sh  \
    && bash ./install.sh  \
	&& rm ./install.sh
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install python tools
# RUN wget https://bootstrap.pypa.io/pip/get-pip.py  \
# 	&&  ./get-pip.py  \
# 	&& python ./get-pip.py  \
# 	&& rm ./get-pip.py
# RUN python3.8 -m pip install --upgrade setuptools wheel pip  \
# 	&& python3.8 -m pip install mako meson qdarkstyle rospkg pyyaml toposort docker docker qtawesome tmuxp  \
# 	&& rm -rf ~/.cache/pip


##################################### 以下内容 不适用 ###################################

# Setup ENV vars for vcpkg
# ENV VCPKG_ROOT=/usr/local/vcpkg \
#     VCPKG_DOWNLOADS=/usr/local/vcpkg-downloads
# ENV PATH="${PATH}:${VCPKG_ROOT}"

# ARG USERNAME=vscode

# Install vcpkg itself: https://github.com/microsoft/vcpkg/blob/master/README.md#quick-start-unix
# COPY scripts/install.sh /tmp/
# RUN chmod +x /tmp/install.sh \
#     && ./tmp/install.sh ${USERNAME} \
#     && rm -f /tmp/install.sh

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
