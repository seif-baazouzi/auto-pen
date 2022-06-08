FROM golang

RUN useradd -ms /bin/bash user
USER user

WORKDIR /home/user

COPY go.mod .
RUN go mod download

COPY --chown=user:user . .

RUN go build ./main.go

CMD ./main
