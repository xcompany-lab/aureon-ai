---
triggers:
  - google drive
  - acessar drive
  - listar arquivos
  - drive files
  - meu drive
  - files no drive
  - pasta do drive
  - download drive
  - upload drive
skill_name: drive-access
version: "1.0.0"
description: Access Google Drive files and folders via MCP server
created_at: 2026-03-08
author: Aureon AI
tags: [google-drive, mcp, storage, files]
---

# Google Drive Access Skill

Access, list, read, and manage files in Google Drive using the MCP (Model Context Protocol) server.

## When to Activate

This skill activates when the user wants to:
- List files or folders in Google Drive
- Read/download files from Drive
- Upload files to Drive
- Search for files in Drive
- Share files or get sharing links
- Manage Drive permissions

## Trigger Examples

- "Liste os arquivos da pasta 'Projetos' no meu Drive"
- "Baixe o arquivo 'Relatorio-Q1.pdf' do Drive"
- "Mostre os arquivos compartilhados comigo"
- "Faça upload deste arquivo para o Drive"
- "Consegue acessar meu Drive?"

## Prerequisites

### 1. Google OAuth Credentials

You need to configure Google OAuth credentials in `.env`:

```bash
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

**How to get credentials:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Google Drive API**
4. Go to **Credentials** → **Create Credentials** → **OAuth client ID**
5. Choose **Desktop app**
6. Download credentials JSON
7. Extract `client_id` and `client_secret` to `.env`

### 2. MCP Server Configuration

The `.mcp.json` file should have:

```json
{
  "mcpServers": {
    "gdrive": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gdrive"],
      "env": {
        "GDRIVE_CLIENT_ID": "${GOOGLE_CLIENT_ID}",
        "GDRIVE_CLIENT_SECRET": "${GOOGLE_CLIENT_SECRET}"
      }
    }
  }
}
```

### 3. First-Time Authentication

On first use, you'll need to authenticate:

1. MCP server will provide an OAuth URL
2. Open URL in browser
3. Sign in with Google account
4. Grant Drive permissions
5. Token saved automatically in `~/.config/gdrive/`

## Available MCP Tools

The Google Drive MCP server provides these tools (auto-available in Claude Code):

| Tool | Description | Example |
|------|-------------|---------|
| `gdrive_list_files` | List files in a folder | List all PDFs in "Documents" |
| `gdrive_read_file` | Read file contents | Read "meeting-notes.txt" |
| `gdrive_search` | Search files by query | Find files containing "Q1 2026" |
| `gdrive_get_file_metadata` | Get file details | Get info about file ID |
| `gdrive_download_file` | Download file | Download "report.pdf" |
| `gdrive_upload_file` | Upload file | Upload local file to Drive |
| `gdrive_create_folder` | Create new folder | Create "Backups" folder |
| `gdrive_share_file` | Share file/get link | Get sharing link for file |

## How to Use

### Example 1: List Files in Folder

**User:** "Liste os arquivos da pasta 'Projetos' no meu Drive"

**Assistant Action:**

```
I'll use the gdrive_list_files MCP tool to list files in your "Projetos" folder.

[MCP tool call: gdrive_list_files with folder_name="Projetos"]

I found 12 files in your Projetos folder:
- relatorio-vendas-q1.pdf (2.3 MB)
- apresentacao-produto.pptx (8.1 MB)
- notas-reuniao.docx (42 KB)
...
```

### Example 2: Read File Contents

**User:** "Leia o conteúdo do arquivo 'notas-reuniao.txt'"

**Assistant Action:**

```
[MCP tool call: gdrive_search with query="notas-reuniao.txt"]
[MCP tool call: gdrive_read_file with file_id="..."]

Here's the content of notas-reuniao.txt:

[File contents displayed]
```

### Example 3: Download File

**User:** "Baixe o arquivo 'Relatorio-Q1.pdf' do Drive"

**Assistant Action:**

```
[MCP tool call: gdrive_search with query="Relatorio-Q1.pdf"]
[MCP tool call: gdrive_download_file with file_id="..." destination="/tmp/Relatorio-Q1.pdf"]

✅ File downloaded successfully to: /tmp/Relatorio-Q1.pdf
```

### Example 4: Search Files

**User:** "Procure arquivos que contenham 'orçamento' no nome"

**Assistant Action:**

```
[MCP tool call: gdrive_search with query="name contains 'orçamento'"]

Found 3 files matching 'orçamento':
1. orcamento-marketing-2026.xlsx
2. orcamento-anual-v2.pdf
3. planilha-orcamento.sheets
```

## Response Template

### Successful File Listing

```
📁 Arquivos encontrados em [FOLDER]:

1. [FILE_NAME] ([SIZE])
   - Tipo: [MIME_TYPE]
   - Modificado: [DATE]
   - Link: [SHARING_LINK]

2. ...

Total: [COUNT] arquivos
```

### Successful Download

```
✅ Arquivo baixado com sucesso!

📄 [FILE_NAME]
📍 Localização: [LOCAL_PATH]
📊 Tamanho: [SIZE]
🔗 Drive ID: [FILE_ID]
```

### Error Handling

```
❌ Não consegui acessar seu Google Drive.

Erro: [ERROR_MESSAGE]

Possíveis soluções:
- Verifique se as credenciais OAuth estão configuradas em `.env`
- Re-autentique: [Provide OAuth URL]
- Verifique permissões da API no Google Cloud Console
```

## Common Use Cases

### 1. Ingest Material from Drive

**User:** "Baixe todos os PDFs da pasta 'Materiais Expert' e processe via /ingest"

**Workflow:**
1. List files: `gdrive_list_files(folder="Materiais Expert", type="pdf")`
2. For each file:
   - Download: `gdrive_download_file(file_id, destination)`
   - Ingest: `SlashCommand("/ingest [path]")`

### 2. Export Knowledge Base to Drive

**User:** "Faça backup do knowledge base no Drive"

**Workflow:**
1. Zip knowledge base: `tar -czf knowledge.tar.gz knowledge/`
2. Upload: `gdrive_upload_file(source, folder="Backups")`
3. Share link: `gdrive_share_file(file_id)`

### 3. Sync Company Documents

**User:** "Sincronize documentos da empresa do Drive para agents/sua-empresa/"

**Workflow:**
1. List files in Drive folder
2. Download each file
3. Move to `agents/sua-empresa/KNOWLEDGE/`
4. Update dossier index

## Technical Details

### MCP Server

- **Package:** `@modelcontextprotocol/server-gdrive`
- **Protocol:** Model Context Protocol (MCP)
- **Transport:** stdio (Node.js process)
- **Auth:** OAuth 2.0 (3-legged flow)

### Token Storage

Credentials stored in:
```
~/.config/gdrive/
├── credentials.json    # OAuth client credentials
└── token.json         # Access/refresh tokens
```

**Security:**
- Tokens auto-refresh when expired
- Never committed to git (in .gitignore)
- Scoped to Drive API only

### File Type Mapping

| Google Drive Type | Download Format |
|-------------------|----------------|
| Google Docs | .docx or .txt |
| Google Sheets | .xlsx or .csv |
| Google Slides | .pptx or .pdf |
| Google Forms | .pdf |
| PDFs | .pdf (native) |
| Images | .png, .jpg (native) |

## Limitations

1. **File Size:**
   - Max download: 100 MB (MCP limitation)
   - Large files require direct API usage

2. **Rate Limits:**
   - Google Drive API: 1000 requests/100 seconds/user
   - Automatic backoff on quota exceeded

3. **Permissions:**
   - Can only access files user has permission to view
   - Cannot access files in Team Drives without explicit permissions

4. **File Types:**
   - Native Google formats require export conversion
   - Some formats may lose formatting on export

## Troubleshooting

### Issue: "OAuth URL not opening"

**Solution:**
```bash
# MCP server will print URL in logs
# Copy and paste manually in browser
# Look for: "Please visit this URL to authorize: https://..."
```

### Issue: "Token expired"

**Solution:**
```bash
# Delete old token
rm ~/.config/gdrive/token.json

# Re-authenticate on next request
# MCP server will prompt for OAuth flow
```

### Issue: "File not found"

**Solution:**
- Use `gdrive_search` first to get correct file ID
- Check if file is in Trash
- Verify file permissions (may be private)

### Issue: "Quota exceeded"

**Solution:**
- Wait 100 seconds for quota reset
- Reduce number of concurrent requests
- Use batch operations when possible

## Integration with Other Skills

### With `/ingest`

```bash
# Download Drive file → Ingest into knowledge base
1. gdrive_search("expert-video-transcript.txt")
2. gdrive_download_file(id, "/tmp/transcript.txt")
3. SlashCommand("/ingest /tmp/transcript.txt --person 'Alex Hormozi'")
```

### With `/process-company-inbox`

```bash
# Sync company docs from Drive
1. gdrive_list_files(folder="Empresa XYZ - Docs")
2. Download all files to inbox/sua-empresa/
3. SlashCommand("/process-company-inbox")
```

### With `send-whatsapp`

```bash
# Share Drive file link via WhatsApp
1. gdrive_share_file(file_id, visibility="anyone")
2. Get sharing link
3. SlashCommand with send-whatsapp skill
```

## Security Best Practices

1. **Least Privilege:**
   - Request only necessary Drive scopes
   - Use read-only scope if not uploading

2. **Credential Management:**
   - Never hardcode OAuth credentials
   - Use environment variables only
   - Rotate secrets regularly

3. **Data Privacy:**
   - Don't log file contents
   - Clear temporary downloads after processing
   - Use encrypted storage for sensitive files

4. **Access Control:**
   - Review OAuth consent scopes
   - Revoke access when no longer needed
   - Monitor Drive activity logs

## Next Steps After Setup

1. ✅ Configure OAuth credentials in `.env`
2. ✅ Verify `.mcp.json` configuration
3. ✅ Restart Claude Code to load MCP server
4. ✅ Test authentication flow
5. ✅ List files in root folder
6. ⏭️ Create automated Drive → Inbox sync
7. ⏭️ Add scheduled backup to Drive

## Support

**MCP Server Docs:**
https://github.com/modelcontextprotocol/servers/tree/main/gdrive

**Google Drive API:**
https://developers.google.com/drive/api/v3/reference

**OAuth 2.0 Setup:**
https://developers.google.com/identity/protocols/oauth2

**Aureon AI:**
`.claude/skills/drive-access/SKILL.md`

## Quick Reference

```bash
# Check MCP server status
# (Claude Code will show MCP tools in tool palette)

# Re-authenticate
rm ~/.config/gdrive/token.json

# View MCP logs
# (Check Claude Code output panel)

# Test MCP connection
# Ask: "Liste arquivos do meu Drive"
```

## Setup Checklist

- [ ] Google Cloud project created
- [ ] Drive API enabled
- [ ] OAuth credentials generated (Desktop app)
- [ ] `GOOGLE_CLIENT_ID` added to `.env`
- [ ] `GOOGLE_CLIENT_SECRET` added to `.env`
- [ ] `.mcp.json` configured with gdrive server
- [ ] Claude Code restarted
- [ ] OAuth flow completed
- [ ] Test query: "List my Drive files"

---

**Status:** 🟢 Ready (after OAuth setup)
**Last updated:** 2026-03-08
**Author:** Aureon AI
