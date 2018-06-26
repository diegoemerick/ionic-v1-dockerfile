FROM debian:jessie

MAINTAINER contamobi

# Versions
ENV IONIC_VERSION 2.2.3
ENV CORDOVA_VERSION 6.5.0
ENV NODE_VERSION 8.9.0
ENV NPM_VERSION 6.0.1
ENV ANDROID_VERSION 24.4.1
ENV GRADLE_VERSION 4.8

# Install basics 
RUN apt-get update &&  \
    apt-get install -y git wget curl && \
        apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update &&  \
    apt-get install build-essential -y  && \
    apt-get install nodejs -y && \
    ln -s /usr/bin/nodejs /usr/local/bin/node && \
    apt-get clean

# Install npm packages
RUN npm install -g n
RUN n 8.9.0
RUN npm install -g npm@$NPM_VERSION
RUN npm install -g cordova@$CORDOVA_VERSION
RUN npm install -g ionic@$IONIC_VERSION
RUN npm install -g grunt-cli
RUN npm install -g gulp
RUN npm install -g bower


#ANDROID
#JAVA
# ENV DEBIAN_FRONTEND noninteractive
RUN dpkg-reconfigure debconf -f Noninteractive

# install python-software-properties (so you can do add-apt-repository)
RUN apt-get update && \
    apt-get install -y -q python-software-properties software-properties-common && \
    apt-get clean

# install oracle java from PPA
# RUN add-apt-repository ppa:webupd8team/java -y
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
# echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
# RUN apt-get update && apt-get -y install oracle-java7-installer && apt-get clean

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update &&  \
    apt-get install -y oracle-java8-installer && \
    apt-get install unzip zip && \
    apt-get clean

#ANDROID STUFF
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --force-yes expect ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod && \
    apt-get clean

# Instal Gradle
RUN \
    cd /usr/local && \
    curl -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle-${GRADLE_VERSION}-bin.zip && \
    rm gradle-${GRADLE_VERSION}-bin.zip

ENV GRADLE_HOME /usr/local/gradle-${GRADLE_VERSION}
ENV PATH $PATH:${GRADLE_HOME}/bin

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install sdk elements
ENV PATH ${PATH}:/opt/tools
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment
RUN cd /opt &&\
    wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \  
    tar xzf android-sdk_r24.4.1-linux.tgz && \    
    rm android-sdk_r24.4.1-linux.tgz && \ 
    (echo y | android-sdk-linux/tools/android -s update sdk --no-ui --filter platform-tools,tools -a ) && \  
    (echo y | android-sdk-linux/tools/android -s update sdk --no-ui --filter extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository -a) && \    
    (echo y | android-sdk-linux/tools/android -s update sdk --no-ui --filter build-tools-27.0.3,android-24 -a) && \
    (echo y | $ANDROID_HOME/tools/bin/sdkmanager --update)

RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.3"