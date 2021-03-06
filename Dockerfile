FROM node:14.15.4-stretch

# Install calibri
RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
    dbus \
    python3 \
	  python3-xdg \
    jq && \
 echo "**** install calibre ****" && \
 mkdir -p \
    /opt/calibre && \
 if [ -z ${CALIBRE_RELEASE+x} ]; then \
    CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" \
    | jq -r .tag_name); \
 fi && \
 CALIBRE_VERSION="$(echo ${CALIBRE_RELEASE} | cut -c2-)" && \
 CALIBRE_URL="https://download.calibre-ebook.com/${CALIBRE_VERSION}/calibre-${CALIBRE_VERSION}-x86_64.txz" && \
 curl -o \
    /tmp/calibre-tarball.txz -L \
    "$CALIBRE_URL" && \
 tar xvf /tmp/calibre-tarball.txz -C \
    /opt/calibre && \
 /opt/calibre/calibre_postinstall && \
 dbus-uuidgen > /etc/machine-id && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
  /tmp/* \
  /var/lib/apt/lists/* \
  /var/tmp/*


WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

CMD ["npm", "start"]
