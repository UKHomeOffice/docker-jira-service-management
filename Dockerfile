FROM atlassian/jira-servicemanagement:4.17.1-jdk11

ENV JIRA_HOME /var/atlassian/application-data/jira
ENV JIRA_INSTALL_DIR /opt/atlassian/jira
ENV JAVA_HOME /opt/java/openjdk

RUN apt-get update && apt-get install -y \
    xmlstarlet \ 
    wget

RUN echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote=true ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote.port=8099 ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote.rmi.port=8099 ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote.local.only=true ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote.host=localhost ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Djava.rmi.server.hostname=localhost ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote.authenticate=false ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote.ssl=false ${CATALINA_OPTS}"' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh \
    && echo 'export CATALINA_OPTS' >> ${JIRA_INSTALL_DIR}/bin/setenv.sh

RUN wget https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem -O /usr/local/share/ca-certificates/rds-ca-2019-root.pem \
    && wget https://truststore.pki.rds.amazonaws.com/eu-west-2/eu-west-2-bundle.pem -O /usr/local/share/ca-certificates/eu-west-2-bundle.pem \
    && update-ca-certificates

RUN keytool -importcert -alias rdsRootCA  -file /usr/local/share/ca-certificates/rds-ca-2019-root.pem -noprompt -storepass changeit -trustcacerts -keystore "${JAVA_HOME}/lib/security/cacerts" \
    && keytool -importcert -alias rdsRegionCA -file /usr/local/share/ca-certificates/eu-west-2-bundle.pem -noprompt -storepass changeit -trustcacerts -keystore "${JAVA_HOME}/lib/security/cacerts"

RUN set -x \
    && usermod -u 1000 jira \
    && groupmod -g 1000 jira \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R jira:jira      "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL_DIR}/conf/Catalina/localhost" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/conf" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/logs" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/temp" \
    && chmod -R 700            "${JIRA_INSTALL_DIR}/work" \
    && chown -R jira:jira      "${JIRA_INSTALL_DIR}/conf" \
    && chown -R jira:jira      "${JIRA_INSTALL_DIR}/logs" \
    && chown -R jira:jira      "${JIRA_INSTALL_DIR}/temp" \
    && chown -R jira:jira      "${JIRA_INSTALL_DIR}/work" \
    && touch -d "@0"           "${JIRA_INSTALL_DIR}/conf/server.xml"
    # && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/jira-application.properties" \

RUN curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.49.tar.gz" | tar -xz --directory "${JIRA_INSTALL_DIR}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.49/mysql-connector-java-5.1.49-bin.jar" 

USER 1000

ADD --chown=jira:jira config/jira-config.properties ${JIRA_HOME}

EXPOSE 8080

VOLUME ["/var/atlassian/application-data/jira", "/opt/atlassian/jira"]

WORKDIR ${JIRA_HOME}

COPY "docker-entrypoint.sh" "/"

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]

