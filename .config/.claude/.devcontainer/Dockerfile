FROM node:20

ARG TZ
ENV TZ="$TZ"

# Install basic development tools and iptables/ipset
RUN apt update && apt install -y \
  # 基本ツール
  less git procps sudo fzf zsh man-db unzip gnupg2 \
  # ネットワークツール
  iptables ipset iproute2 dnsutils aggregate \
  # 開発ツール
  jq curl wget gh ripgrep \
  # ビルドツール
  build-essential ca-certificates \
  # Python関連
  python3 python3-pip python3-venv \
  # その他
  vim neovim

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Install Powerlevel10k theme
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -t robbyrussell \
  -p git \
  -p fzf \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-syntax-highlighting \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/node/.powerlevel10k
RUN chown -R node:node /home/node/.powerlevel10k

# Install Claude
RUN npm install -g @anthropic-ai/claude-code

# Install modern tools (as node user)
USER node

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/node/.cargo/bin:$PATH"

# Install lsd (modern ls)
RUN /home/node/.cargo/bin/cargo install lsd

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/node/.local/bin:$PATH"

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/node/.bun/bin:$PATH"

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh
ENV PATH="/home/node/.deno/bin:$PATH"

# Switch back to root for remaining setup
USER root

# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node