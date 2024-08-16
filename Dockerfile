# FROM devopsfaith/krakend:2.7

# COPY . /etc/krakend/

# RUN FC_ENABLE=1 \
# FC_SETTINGS="config/settings" \
# FC_TEMPLATES="config/templates" \
# krakend check -t -d -c "config/sample.json"

# ENTRYPOINT FC_ENABLE=1 \
# FC_SETTINGS="/etc/krakend/config/settings"\
# FC_TEMPLATES="/etc/krakend/config/templates" \
# krakend run -c "/etc/krakend/config/sample.json"


FROM devopsfaith/krakend:2.7 as builder
# ARG ENV=prod

COPY config/krakend.tmpl .
COPY config/settings /etc/krakend/settings 
COPY config/templates /etc/krakend/templates

## Save temporary file to /tmp to avoid permission errors
RUN FC_ENABLE=1 \
    FC_OUT=/tmp/krakend.json \
    FC_SETTINGS="/etc/krakend/settings" \
    FC_TEMPLATES="/etc/krakend/templates" \
    krakend check -d -t -c "krakend.tmpl" --lint

FROM devopsfaith/krakend:2.7
# Keep operating system updated with security fixes between releases
RUN apk upgrade --no-cache --no-interactive

COPY --from=builder --chown=krakend:nogroup /tmp/krakend.json .
# Uncomment with Enterprise image:
# COPY LICENSE /etc/krakend/LICENSE