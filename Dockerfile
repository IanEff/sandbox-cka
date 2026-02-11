FROM alpine AS builder
COPY ./crasher.c /
RUN apk --update add gcc musl-dev && \
    gcc -g -o crasher crasher.c

FROM alpine
COPY --from=builder /crasher /crasher
CMD [ "/crasher" ]
