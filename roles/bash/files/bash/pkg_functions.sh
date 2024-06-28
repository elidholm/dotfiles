#!/usr/bin/env bash

go-upgrade() {
    # if no arg is passed, get latest version
    if [[ -z $1 ]]; then
        VERSION=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
      else
        VERSION="go$1"
    fi
    OS=linux
    ARCH=amd64
    pushd /tmp > /dev/null 2>&1 || exit 1
    echo -e "${ARROW} ${GREEN}Downloading upgrade $VERSION...${NC}"
    wget -q https://storage.googleapis.com/golang/"$VERSION".$OS-$ARCH.tar.gz
    echo -e "${ARROW} ${GREEN}Extracting...${NC}"
    tar -xvf "$VERSION".$OS-$ARCH.tar.gz > /dev/null 2>&1
    sudo rm -rf /usr/local/go
    echo -e "${ARROW} ${GREEN}Installing...${NC}"
    sudo mv go /usr/local
    popd > /dev/null 2>&1 || exit 1
    echo -e "${CHECK_MARK} ${GREEN}Successfully Installed GO Version: ${YELLOW}$(/usr/local/go/bin/go version)${NC}"
}

