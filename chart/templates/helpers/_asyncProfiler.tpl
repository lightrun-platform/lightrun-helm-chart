{{- define "asyncProfiler.initContainer.download-async-profiler" -}}
- name: download-async-profiler
  image: "lightruncom/chart-helper:latest"
  imagePullPolicy: IfNotPresent
  command: 
    - sh
    - -c
    - |
      set -ex
      cd /tmp
      wget -O - $(wget -qO- https://api.github.com/repos/async-profiler/async-profiler/releases/tags/{{ .version }} | grep browser_download_url | awk '/async-profiler-.*linux-{{ .architecture }}.*\.tar\.gz/ { print $2 }' | tr -d '"')
      tar xvf async-profiler-*.tar.gz
      cp -r async-profiler-*/* /async-profiler
  resources:
    limits:
      memory: "100Mi"
      cpu: "100m"
    requests:
      memory: "100Mi"
      cpu: "100m"
  volumeMounts:
    - name: async-profiler-download
      mountPath: /async-profiler
{{- end -}}


{{- define "asyncProfiler.container.persist-async-profiler-output-files" -}}
- name: persist-async-profiler-output-files
  image: "lightruncom/chart-helper:latest"
  imagePullPolicy: IfNotPresent
  command: 
    - sh
    - -c
    - |
      mkdir -p /async-profiler-persistent/$POD_NAME
      cd /async-profiler-tmp
      echo "Start watching files in /async-profiler-tmp"
      while :; do
        # Take all files except one which AP continues writing to
        files=$(ls | sort -r | tail -n +2)
        if [[ -n "$files" ]]; then
          {{/* https://unix.stackexchange.com/a/131266 */}}
          cp $files /async-profiler-persistent/$POD_NAME/
          rm $files
        fi
        sleep 60
      done
  lifecycle:
    preStop:
      exec:
        command:
          - sh
          - -c
          - |
            echo Persisting all left files
            sleep 5
            mkdir -p /async-profiler-persistent/$POD_NAME
            find /async-profiler-tmp -type f -print0 -exec mv -v -t  /async-profiler-persistent/$POD_NAME \{\} \+
            echo Done
  resources:
    limits:
      memory: "100Mi"
      cpu: "100m"
    requests:
      memory: "100Mi"
      cpu: "100m"
  env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.name
  volumeMounts:
    - name: async-profiler-persistent
      mountPath: /async-profiler-persistent
    - name: async-profiler-tmp
      mountPath: /async-profiler-tmp
{{- end -}}


{{- define "asyncProfiler.volumes" -}}
{{- if .persistence.enabled -}}  
- name: async-profiler-persistent
  persistentVolumeClaim:
    claimName: {{ .persistence.existingClaim }}
{{- end }}
- name: async-profiler-tmp
  emptyDir:
    sizeLimit: 10Gi
- name: async-profiler-download
  emptyDir:
    sizeLimit: 50Mi
{{- end -}}


{{- define "asyncProfiler.volumeMounts" -}}
- name: async-profiler-tmp
  mountPath: /async-profiler-tmp
- name: async-profiler-download
  mountPath: "/async-profiler"
{{- end -}}


{{- define "asyncProfiler.java.agentpath" -}}
-agentpath:/async-profiler/lib/libasyncProfiler.so={{ .arguments }}
{{- end -}}
