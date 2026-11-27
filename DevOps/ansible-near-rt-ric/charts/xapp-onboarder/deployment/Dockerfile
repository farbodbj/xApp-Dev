# The setup.py file in https://github.com/o-ran-sc/ric-plt-appmgr says python >= 3.6 but update with caution, packages such as pkg_resources or some deprecated modules in urllib are used in this project
FROM python:3.9-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://gerrit.o-ran-sc.org/r/ric-plt/appmgr /appmgr

WORKDIR /appmgr/xapp_orchestrater/dev/xapp_onboarder

RUN pip install --no-cache-dir .

# We use this base image to create a K8s jobs that onboards an xApp using the dms_cli tool

# This approach is chosen to minimize the commands that should be run directly on a k8s node, a scenario that is not realistic in production k8s environments