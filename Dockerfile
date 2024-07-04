FROM ubuntu

RUN apt update && apt install -y libfontconfig1

EXPOSE 1609

WORKDIR /opt/pistas

COPY . .

ENTRYPOINT ["/opt/pistas/pistas_server.x86_64", "--headless", "--", "--server"]