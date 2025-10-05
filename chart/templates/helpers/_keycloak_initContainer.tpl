{{ define "lightrun-keycloak.initContainer.read-only-rootfs" }}
      - args:
          - >
            cp -R /opt/* /keycloak-empty-dir/ &&
            cd /opt &&
            find . -type f -exec touch -r {} /keycloak-empty-dir/{} \; 2>/dev/null
        command:
          - /bin/sh
          - -c
        image: "{{ .Values.deployments.keycloak.image.repository }}:{{ .Values.deployments.keycloak.image.tag }}"
        imagePullPolicy: {{ .Values.deployments.keycloak.image.pullPolicy }}
        name: prepare-readonlyfs
        securityContext: {{- include "lightrun-keycloak.containerSecurityContext" . | indent 10 }}
        resources:
          requests:
            cpu: {{ .Values.deployments.keycloak.resources.cpu }}
            memory: {{ .Values.deployments.keycloak.resources.memory }}
          limits:
            cpu: {{ .Values.deployments.keycloak.resources.cpu }}
            memory: {{ .Values.deployments.keycloak.resources.memory }}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
          - mountPath: /keycloak-empty-dir
            name: tmpfs
            subPath: opt
{{ end }}

{{ define "lightrun-keycloak.initContainer.wait-for-db" }}
      - name: wait-for-mysql
        image: {{ .Values.deployments.mysql.image.repository }}:{{ .Values.deployments.mysql.image.tag }}
        imagePullPolicy: {{ .Values.deployments.mysql.image.pullPolicy }}
        securityContext: {{- include "mysql.containerSecurityContext" . | indent 12 }}
        resources:
          limits:
            memory: "100Mi"
            cpu: "100m"
          requests:
            memory: "100Mi"
            cpu: "100m"
        command: ["sh", "-c"]
        args: 
          - while ! mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h {{ include "mysql.db_endpoint" . }} -e "SELECT 1" {{ if not .Values.general.db_require_secure_transport }}--ssl-mode=DISABLED{{ end }} --connect-timeout 2; do sleep 1; done
        env:
          - name: MYSQL_USER
            valueFrom:
              secretKeyRef:
                name: {{ include "secrets.keycloak.name" . }}
                key: DB_USER
          - name: MYSQL_PASSWORD
            valueFrom:
              secretKeyRef:
                name: {{ include "secrets.keycloak.name" . }}
                key: DB_PASSWORD
          - name: MYSQL_TCP_PORT
            value: "3306"
{{ end }}


{{ define "lightrun-keycloak.initContainer.cluster-certs" }}
      - name: cluster-cert
        image: "{{ .Values.deployments.keycloak.initContainers.cluster_cert.image.repository }}:{{ .Values.deployments.keycloak.initContainers.cluster_cert.image.tag }}"
        imagePullPolicy: {{ .Values.deployments.keycloak.initContainers.cluster_cert.image.pullPolicy }}
        securityContext: {{- include "lightrun-keycloak.containerSecurityContext" . | indent 10 }}
        resources:
          limits:
            memory: "100Mi"
            cpu: "100m"
          requests:
            memory: "100Mi"
            cpu: "100m"
        env:
        - name: KEYSTORE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ include "secrets.backend.name" . }}
              key: KEYSTORE_PASSWORD
        volumeMounts:
        - name: cluster-cert
          mountPath: /tls
        - name: p12
          mountPath: /p12
        command: ['sh', '-c', 'openssl pkcs12 -export -out /p12/cluster.p12 -inkey /tls/tls.key -in /tls/tls.crt -passin pass:$KEYSTORE_PASSWORD -passout pass:$KEYSTORE_PASSWORD']
      - name: cluster-cert-ca
        image: "{{ .Values.deployments.keycloak.image.repository }}:{{ .Values.deployments.keycloak.image.tag }}"
        imagePullPolicy: {{ .Values.deployments.keycloak.image.pullPolicy }}
        securityContext: {{- include "lightrun-keycloak.containerSecurityContext" . | indent 10 }}
        resources:
          limits:
            memory: "100Mi"
            cpu: "100m"
          requests:
            memory: "100Mi"
            cpu: "100m"
        env:
        - name: KEYSTORE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ include "secrets.backend.name" . }}
              key: KEYSTORE_PASSWORD
        volumeMounts:
        - name: cluster-cert
          mountPath: /tls
        - name: p12
          mountPath: /p12
        command: ['sh', '-c', 'keytool -import -trustcacerts -alias internalCa -keystore /p12/cluster-ca.p12 -file  /tls/ca.crt -noprompt -storepass $KEYSTORE_PASSWORD']
{{ end }}