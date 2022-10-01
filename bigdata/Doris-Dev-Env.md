FROM apache/incubator-doris:build-env-latest

USER root
WORKDIR /root
RUN echo '1234' | passwd root --stdin

RUN yum install -y vim net-tools man wget git mysql lsof bash-completion \
        && cp /var/local/thirdparty/installed/bin/thrift /usr/bin

# 更安全的使用，创建用户而不是使用 root
RUN yum install -y sudo \
        && useradd -ms /bin/bash yuanoOo && echo 1234 | passwd yuanoOo --stdin \
        && usermod -a -G wheel yuanoOo

USER yuanoOo
WORKDIR /home/yuanoOo
RUN git config --global color.ui true \
        && git config --global user.email "zhao137578346@gmail.com" \
        && git config --global user.name "yuanoOo"

# 按需安装 zsh and oh my zsh, 更易于使用，不需要的移除
USER root
RUN yum install -y zsh \
        && chsh -s /bin/zsh yuanoOo
USER yuanoOo
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh \
        && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
        && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting