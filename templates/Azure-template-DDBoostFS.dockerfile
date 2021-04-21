# Copy DDBoostFS
COPY src/packages/DockerEmbebed/ddboostfs/DDBoostFS*.rpm /tmp
# Install DDBoostFS
RUN yum localinstall -y /tmp/DDBoostFS*.rpm
