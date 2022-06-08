FROM python

RUN useradd -ms /bin/bash user
USER user

WORKDIR /home/user

RUN pip install flask
RUN pip install pymongo

COPY --chown=user:user . .

CMD python server.py
