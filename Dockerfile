# FROM tomcat:latest
# RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps
# COPY ./*.war /usr/local/tomcat/webapps

FROM tomcat:latest

# Copy default Tomcat webapps (if needed)
RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps

# Ensure that the WAR file is correctly copied from the target directory
COPY target/*.war /usr/local/tomcat/webapps/

