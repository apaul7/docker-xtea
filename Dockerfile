FROM ubuntu:bionic

LABEL \
  description="Image for running xTea, https://github.com/parklab/xTea" \
  maintainer="Alexander Paul<alex.paul@wustl.edu>"

RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    bzip2 \
    gcc \
    git \
    libcurl4-openssl-dev \
    libbz2-dev \
    liblzma-dev \
    libssl1.0.0 \
    libssl-dev \
    make \
    ncurses-dev \
    tabix \
    vim \
    wget \
    zlib1g-dev

WORKDIR /tmp

##########
# HTSLIB #
##########
ENV HTSLIB_VERSION=1.10.2
ENV HTSLIB_INSTALL=/opt/htslib/
RUN wget https://github.com/samtools/htslib/releases/download/$HTSLIB_VERSION/htslib-$HTSLIB_VERSION.tar.bz2 && \
    tar --bzip2 -xf htslib-$HTSLIB_VERSION.tar.bz2 && \
    cd /tmp/htslib-$HTSLIB_VERSION && \
    make prefix=$HTSLIB_INSTALL && \
    make prefix=$HTSLIB_INSTALL install && \
    ln -s $HTSLIB_INSTALL/bin/* /usr/local/bin/ && \
    rm -rf /tmp/htslib-$HTSLIB_VERSION /tmp/htslib-$HTSLIB_VERSION.tar.bz2

############
# samtools #
############
ENV SAMTOOLS_VERSION=1.9
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
RUN wget https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 && \
    tar --bzip2 -xf samtools-$SAMTOOLS_VERSION.tar.bz2 && \
    cd /tmp/samtools-$SAMTOOLS_VERSION && \
    make prefix=$SAMTOOLS_INSTALL_DIR && \
    make prefix=$SAMTOOLS_INSTALL_DIR install && \
    ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/local/bin/samtools && \
    rm -rf /tmp/samtools-$SAMTOOLS_VERSION /tmp/samtools-$SAMTOOLS_VERSION.tar.bz2

#######
# BWA #
#######
ENV BWA_VERSION=0.7.17
RUN wget -q http://downloads.sourceforge.net/project/bio-bwa/bwa-${BWA_VERSION}.tar.bz2 && tar xvf bwa-${BWA_VERSION}.tar.bz2 && \
    cd /tmp/bwa-${BWA_VERSION} && \
    sed -i 's/CFLAGS=\\t\\t-g -Wall -Wno-unused-function -O2/CFLAGS=-g -Wall -Wno-unused-function -O2 -static/' Makefile && \
    make && \
    cp /tmp/bwa-${BWA_VERSION}/bwa /usr/local/bin && \
    rm -rf /tmp/

############
# bcftools #
############
ENV BCFTOOLS_VERSION=1.9
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/$BCFTOOLS_VERSION/bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  cd /tmp/bcftools-$BCFTOOLS_VERSION && \
  make prefix=$BCFTOOLS_INSTALL_DIR && \
  make prefix=$BCFTOOLS_INSTALL_DIR install && \
  ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/local/bin/bcftools && \
  rm -rf /tmp/bcftools-$BCFTOOLS_VERSION /tmp/bcftools-$BCFTOOLS_VERSION.tar.bz2

# long reads
RUN git clone https://github.com/ruanjue/wtdbg2 && \
  cd wtdbg2 && \
  make && \
  mv wtdbg2 /usr/local/bin/wtdbg2 && \
  mv wtpoa-cns /usr/local/bin/wtpoa-cns && \
  cd .. && rm -rf wtdbg2 

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b \
    -p /miniconda3/ && \
    rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/miniconda3/bin:${PATH}

ENV XTEA_VERSION="0.1.7"
RUN conda config --add channels r && \
    conda config --add channels bioconda && \
    conda create -n xtea xtea=${XTEA_VERSION}

WORKDIR /
