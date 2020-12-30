FROM public.ecr.aws/amazonlinux/amazonlinux:latest


ENV KUBECONFIG /home/kubectl/.kube/kubeconfig
ENV HOME /home/kubectl
# ENV KUBECONFIG /root/.kube/kubeconfig

ARG KUBECTL_VERSION=1.18.8/2020-09-18

RUN yum install -y unzip jq && \
	amazon-linux-extras install docker

# install aws-cli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
	unzip awscliv2.zip && \
	./aws/install


# RUN \
# 	mkdir /root/bin /aws; \
# 	apk -Uuv add groff less bash python py-pip jq curl docker && \
# 	pip install --upgrade pip; \
# 	pip install awscli && \
# 	apk --purge -v del py-pip && \
# 	rm /var/cache/apk/* && \
# 	# Create non-root user (with a randomly chosen UID/GUI).
# 	adduser kubectl -Du 5566

# ADD https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl /usr/local/bin/kubectl
# #COPY kubectl /usr/local/bin/kubectl

# install kubectl
RUN curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
	chmod +x kubectl && \
	mv kubectl /usr/local/bin/kubectl

WORKDIR $HOME

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod a+x /usr/local/bin/kubectl /usr/local/bin/entrypoint.sh


# USER kubectl
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
