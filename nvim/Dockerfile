FROM alpine:latest

# INSTALL NEOVIM, GIT, NODEJS, NPM, DOTNET, AND BASH
RUN apk add --no-cache neovim git curl nodejs npm icu-libs bash dotnet9-sdk aspnetcore9-runtime

# Set npm global prefix for root and add to PATH
ENV NPM_CONFIG_PREFIX=/root/.npm-global
ENV PATH="/root/.npm-global/bin:/usr/local/bin:$PATH"

# COPY CONFIGURATION FILES
COPY . /root/.config/nvim/

# Preload Neovim plugins using lazy.nvim
RUN nvim --headless "+Lazy! sync" +qa

# Set working directory (optional, for plugins, etc.)
WORKDIR /root

# Set default command to launch Neovim
CMD ["nvim"]
