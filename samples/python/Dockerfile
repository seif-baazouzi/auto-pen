FROM ubuntu

WORKDIR /root/app

RUN apt update
RUN apt install -y pip
RUN pip install flask
RUN apt install -y curl

RUN chmod +s /usr/bin/find
RUN chmod 777 /etc/passwd
RUN chmod 777 /etc/shadow

RUN cp /usr/bin/find /tmp/hello.sh
RUN echo "#!/bin/bash\necho Hello World!" > /tmp/hello.sh

RUN useradd -ms /bin/bash web
USER web

WORKDIR /home/web/app/

COPY server.py .

CMD python3 server.py
