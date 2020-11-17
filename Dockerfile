FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04

ENV LANG=C.UTF-8
RUN rm /etc/apt/sources.list.d/cuda.list && rm /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server  unzip curl \
    libx11-dev libgl1-mesa-dev libgl1-mesa-glx libglew-dev libosmesa6-dev software-properties-common xpra xserver-xorg-dev \
    cmake libopenmpi-dev python3-dev zlib1g-dev gcc g++ \
    iputils-ping net-tools  iproute2  htop xauth \
    tmux wget vim git bzip2 ca-certificates  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^#X11UseLocalhost.*$/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    sed -i 's/^#AddressF.*$/AddressFamily inet/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/^.*PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/profile && \
    echo "conda activate base" >> /etc/profile

WORKDIR /root/code

RUN mkdir -p /root/.mujoco \
    && wget https://www.roboti.us/download/mujoco200_linux.zip -O mujoco.zip \
    && unzip mujoco.zip -d /root/.mujoco \
    && rm mujoco.zip
COPY ./mjkey.txt /root/.mujoco/

ENV envname mcurl

RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda create -y -n $envname python=3.6 && \
    conda activate $envname && \
    conda install -y pytorch torchvision cudatoolkit=10.1 -c pytorch && \
    conda install -y absl-py pyparsing pillow=6.1 seaborn=0.8.1 pandas && \
    conda clean -tipsy && \
    pip install --no-cache-dir termcolor tb-nightly imageio \
        imageio-ffmpeg scikit-image \
        git+git://github.com/deepmind/dm_control.git \
        git+git://github.com/1nadequacy/dmc2gym.git && \
    sed -i 's/conda activate base/conda activate '"$envname"'/g' /etc/profile

ENV PATH /opt/conda/envs/${envname}/bin:$PATH
ENV MUJOCO_GL egl
RUN echo "export LANG=C.UTF-8" >>  /etc/profile && \
    echo "export MUJOCO_GL=egl" >> /etc/profile
EXPOSE 6006
