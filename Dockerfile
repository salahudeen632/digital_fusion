FROM ubuntu:18.04


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
  
ENV PATH /opt/conda/bin:$PATH



ENV CONDA_DEFAULT_ENV pv
RUN conda create --name pv
ENV PATH /opt/conda/envs/pv/bin:$PATH
RUN conda init bash \
    && . /root/.bashrc \
RUN conda activate pv && \
    conda install paraview
