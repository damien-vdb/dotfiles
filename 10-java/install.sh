
export SDKMAN_DIR=/opt/sdkman

echo "Installing SDKMan in ${SDKMAN_DIR}"
curl -s "https://get.sdkman.io?rcupdate=false&ci=true" | bash

sdk install maven 3.9.11
sdk install java 25.0.1-graalce