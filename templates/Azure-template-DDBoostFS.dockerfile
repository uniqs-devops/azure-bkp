# Copy DDBoostFS
COPY src/packages/DockerEmbebed/DUMMYVERSION/DDBoostFS*.rpm /tmp
# Install DDBoostFS
RUN yum localinstall -y /tmp/DDBoostFS*.rpm
# Copy DDBoostFS lockbox file
COPY src/ddboostfs/boostfs.lockbox /opt/emc/boostfs/lockbox/boostfs.lockbox
