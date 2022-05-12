FROM ubuntu:18.04
USER root
RUN apt-get update && \
    apt-get upgrade -y --with-new-pkgs -o Dpkg::Options::="--force-confold" && \
    apt-get install -y \
    locales sudo \
    gcc g++ gfortran \
    wget \
    python3 \
    python3-dev \
    python3-numpy \
    libxft2 \
    libxmu6 \
    libxss1 && \
    echo "C.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set locale environment
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

COPY set-home-permissions.sh /etc/my_init.d/set-home-permissions.sh

# Add a new user
RUN adduser --disabled-password --gecos "" ibsim && \
    adduser ibsim sudo && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    rm /etc/my_init.d/10_syslog-ng.init && \
    chmod +x /etc/my_init.d/set-home-permissions.sh

# Create a sharable zone
USER ibsim
RUN touch /home/ibsim/.sudo_as_admin_successful && \
    mkdir /home/ibsim/shared
VOLUME /home/ibsim/shared

WORKDIR /home/ibsim
USER root
ENTRYPOINT ["/sbin/my_init", "--quiet", "--", "/sbin/setuser", "ibsim", "/bin/bash", "-l", "-c"]
CMD ["/bin/bash", "-i"]

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/home/ibsim/VirtualLab/bin:/opt/SalomeMeca/appli_V2019.0.3_universal:/opt/ERMES/ERMES-CPlas-v12.5:${PATH}" \
    BASH_ENV=/home/ibsim/patch.sh

# Get Ubuntu updates and basic packages
USER root
RUN apt-get update && \
    apt-get upgrade -y --with-new-pkgs -o Dpkg::Options::="--force-confold" && \
    apt-get install -y \
    ubuntu-drivers-common \
    tzdata \
    unzip \
    libglu1 \
    nano \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#COPY hello.sh /home/ibsim/hello.sh
COPY patch.sh /home/ibsim/patch.sh
#RUN chmod +x /home/ibsim/hello.sh
#RUN chmod +x /home/ibsim/patch.sh

USER ibsim
WORKDIR /tmp

# Download and install VirtualLab and its requirements
RUN sudo chmod 755 /home/ibsim/patch.sh && \
    wget -O Install_VirtualLab.sh https://gitlab.com/ibsim/virtuallab/-/raw/master/Scripts/Install/Install_VirtualLab.sh?inline=false && \
    chmod 755 Install_VirtualLab.sh && \
    sudo ./Install_VirtualLab.sh -P c -S y -E y -y && \
    sudo rm /home/ibsim/salome_meca-2019.0.3-1-universal.run && \
    sudo rm /home/ibsim/salome_meca-2019.0.3-1-universal.tgz && \
    sudo rm /home/ibsim/Anaconda3-2020.02-Linux-x86_64.sh && \
    sudo rm /home/ibsim/VirtualLab/Scripts/Install/ERMES-CPlas-v12.5.zip

USER root

FROM continuumio/miniconda3:4.9.2 as dependencies

# By default this Dockerfile builds with the latest release of CadQuery 2
ARG cq_version=2.1

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get --allow-releaseinfo-change update
RUN apt-get update -y && \
    apt-get upgrade -y

RUN apt-get install -y libgl1-mesa-glx libgl1-mesa-dev libglu1-mesa-dev  freeglut3-dev libosmesa6 libosmesa6-dev  libgles2-mesa-dev curl imagemagick && \
                       apt-get clean

# Installing CadQuery and Gmsh
ENV PATH /opt/conda/bin:$PATH


ENV CONDA_DEFAULT_ENV paramak_env
RUN conda create --name paramak_env python=3.8

ENV PATH /opt/conda/envs/paramak_env/bin:$PATH
RUN conda init bash \
    && . /root/.bashrc && \
    conda activate paramak_env && \
    conda install -c cadquery -c conda-forge cadquery=master  && \
    conda install -c conda-forge gmsh=4.9.3 && \
    conda install -c conda-forge python-gmsh=4.9.3 && \
    conda install -c conda-forge 'moab>=5.3.0' && \
    pip install paramak
    

ENV PATH /opt/conda/bin:$PATH



ENV CONDA_DEFAULT_ENV openmc_env
RUN conda create --name openmc_env
ENV PATH /opt/conda/envs/openmc_env/bin:$PATH
RUN conda init bash \
    && . /root/.bashrc \
RUN conda activate openmc_env && \
    conda install -c conda-forge mamba && \
    mamba install -c conda-forge openmc && \
    pip install openmc_data_downloader && \
    pip install openmc_tally_unit_converter
  
COPY cad1.py /home/ibsim/cad1.py
