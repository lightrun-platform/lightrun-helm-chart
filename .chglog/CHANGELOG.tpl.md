{{ range .Versions }}
<a name="{{ .Tag.Name }}"></a>
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]({{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}){{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "2006-01-02" .Tag.Date }}

{{ range .CommitGroups }}
{{ if eq .Title "Versions" }}
### {{ .Title }}
{{ range .Commits }}
{{ .Body }}
{{ end }} 
{{ else }}
### {{ .Title }} {{ if eq (len .Commits) 1 }}(1 change){{ else }}({{ len .Commits }} changes){{ end }}
{{ range .Commits }}
- [{{ .Subject }}]({{ $.Info.RepositoryURL }}/commit/{{ .Hash.Short }})
{{ if .Body }}
{{ .Body | nindent 2 }}
{{ end }} 
{{ end }} 
{{ end }} 
{{ end }} 

{{ if .NoteGroups }}
{{ range .NoteGroups }}
### {{ .Title }}
{{ range .Notes }}
{{ .Body }}
{{ end }} 
{{ end }} 
{{ end }} 

{{ end }} 
