FROM ubuntu:18.04


FROM continuumio/miniconda3:latest as dependencies

# By default this Dockerfile builds with the latest release of CadQuery 2
ARG cq_version=2.1

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get --allow-releaseinfo-change update
RUN apt-get update -y && \
    apt-get upgrade -y

RUN apt-get install -y libgl1-mesa-glx libgl1-mesa-dev libglu1-mesa-dev  freeglut3-dev libosmesa6 libosmesa6-dev  libgles2-mesa-dev curl imagemagick && \
                       apt-get clean


ENV PATH /opt/conda/bin:$PATH


RUN chmod 777 -R /opt/conda/
ENV CONDA_DEFAULT_ENV paramak_env
RUN conda create --name paramak_env python=3.8


ENV PATH /opt/conda/envs/paramak_env/bin:$PATH


RUN conda init bash \
    && . /root/.bashrc && \
    conda activate paramak_env && \
    pip install paramak
