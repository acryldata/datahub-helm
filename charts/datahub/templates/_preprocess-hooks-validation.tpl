{{/*
Reject the silent-drop combination from datahub-project/datahub#19119: UI-sourced
writes are stored but never indexed when both the GMS fast path and MAE reprocess
path are off.
*/}}
{{- define "datahub.validate.preprocessHooks" -}}
{{- if and (not .Values.global.datahub.preProcessHooksUIEnabled) (not .Values.global.datahub.reProcessUIEventHooks) -}}
{{- fail "ERROR: global.datahub.preProcessHooksUIEnabled and global.datahub.reProcessUIEventHooks are both false. UI-sourced writes (GraphQL appSource=ui) would be stored but never indexed. Set preProcessHooksUIEnabled=true (GMS synchronous path) or reProcessUIEventHooks=true (MAE consumer path). See https://github.com/datahub-project/datahub/issues/19119" -}}
{{- end -}}
{{- end -}}
