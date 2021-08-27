# Docker Jira Service Management

Docker Image built off the official [Atlassian Docker Images](https://hub.docker.com/r/atlassian/jira-servicemanagement), with some changes made to suit our deployment requirements. Supersedes [Docker Jira Service Desk](https://github.com/UKHomeOffice/docker-jira-service-desk)

| Environment Variable      | Description |
| :------------------------:| :----------: |
| X_PROXY_NAME              | Sets the Tomcat Connectors `ProxyName` attribute    |
| X_PROXY_PORT              | Sets the Tomcat Connectors `ProxyPort` attribute    |
| X_PROXY_SCHEME            | If set to https the Tomcat Connectors `secure=true` and redirectPort equal to `X_PROXY_PORT` |
| X_PATH                    | Sets the Tomcat connectors path attribute |
