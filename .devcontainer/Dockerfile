FROM node

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN if getent passwd $USER_UID > /dev/null; then \
      userdel -r $(getent passwd $USER_UID | cut -d: -f1); \
    fi

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME

RUN apt-get update

RUN apt-get install sudo -y

RUN npm install -g typescript

RUN npm install -g pnpm@latest-10

RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

RUN chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME