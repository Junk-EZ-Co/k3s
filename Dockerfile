# Use a RHEL 8 base image
FROM registry.access.redhat.com/ubi8/ubi:latest

# Install necessary packages
RUN yum update -y && \
    yum install -y selinux-policy selinux-policy-targeted container-selinux && \
    # For systemctl commands
    yum install -y systemd && \
    yum clean all && \
    rm -rf /var/cache/yum

# Disable SELinux for the container - adjust as needed for your security requirements
RUN sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Install Docker CLI for `docker load` command, adjust this if you have a different method to handle Docker commands inside the container
RUN yum install -y yum-utils && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum install -y docker-ce-cli && \
    yum clean all && \
    rm -rf /var/cache/yum

# Copy the k3s binary and air-gap images tarball to the container
COPY k3s /usr/local/bin/k3s
COPY k3s-airgap-images-amd64.tar /k3s-airgap-images-amd64.tar

# Ensure k3s is executable
RUN chmod +x /usr/local/bin/k3s

# Copy your script into the container
COPY master_install.sh /master_install.sh

# Ensure the script is executable
RUN chmod +x /master_install.sh

# Run the script when the container starts, note that running systemctl commands might require additional setup
CMD ["/master_install.sh"]
