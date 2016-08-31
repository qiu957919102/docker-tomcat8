FROM sergeyshkolin/java8

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.26
ENV TOMCAT_TGZ_URL http://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN mkdir -p /usr/local && \
    wget -qO- "$TOMCAT_TGZ_URL" | gunzip | tar x -C /usr/local/ && \
    mv /usr/local/apache-tomcat-*  /usr/local/tomcat 
RUN wget -q -c http://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/extras/tomcat-juli-adapters.jar -O /usr/local/tomcat/lib/tomcat-juli-adapters.jar && \
    wget -q -c http://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/extras/tomcat-juli.jar -O /usr/local/tomcat/lib/tomcat-juli.jar &&\
    wget -q -c http://archive.apache.org/dist/logging/log4j/1.2.17/log4j-1.2.17.jar -O /usr/local/tomcat/lib/log4j-1.2.17.jar && \
    cp /usr/local/tomcat/lib/tomcat-juli.jar /usr/local/tomcat/bin/tomcat-juli.jar && \
    rm -rf /usr/local/tomcat/conf/logging.properties

RUN adduser -D -h /usr/local/tomcat -s /sbin/false tomcat && \
    chown -R tomcat:tomcat /usr/local/tomcat

USER tomcat

EXPOSE 8009 8080
ENTRYPOINT ["java","-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager","-XX:+DisableExplicitGC","-XX:+UseParallelGC","-Xloggc:/var/log/gc.log","-verbose:gc","-XX:+PrintGCDetails","-XX:+HeapDumpOnOutOfMemoryError","-XX:HeapDumpPath=/var/log","-Djava.awt.headless=true","-Dsun.rmi.dgc.client.gcInterval=3600000","-Dsun.rmi.dgc.server.gcInterval=3600000","-Dsun.lang.ClassLoader.allowArraySyntax=true","-XX:+CMSClassUnloadingEnabled","-Djava.endorsed.dirs=/usr/local/tomcat/endorsed","-classpath","/usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar","-Dcatalina.base=/usr/local/tomcat","-Dcatalina.home=/usr/local/tomcat","-Djava.io.tmpdir=/usr/local/tomcat/temp"]

CMD ["-XX:ThreadStackSize=256k","-Xms1024m","-Xmx1024m","-XX:PermSize=512m","-XX:MaxPermSize=512m","org.apache.catalina.startup.Bootstrap","start"]

