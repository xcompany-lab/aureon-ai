from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json
import anthropic
from openai import OpenAI
from dotenv import load_dotenv
from supabase import create_client, Client
from datetime import datetime

# ===========================================================
# AUREON VOICE BRAIN — Powered by the real J.A.R.V.I.S. soul
# With persistent memory across sessions
# ===========================================================

# Load environment variables from root
env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../.env'))
load_dotenv(env_path, override=True)

app = Flask(__name__)
CORS(app)

# Base paths
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..'))
CLAUDE_DIR = os.path.join(BASE_DIR, '.claude/aureon')
STATE_FILE = os.path.join(CLAUDE_DIR, 'STATE.json')
VOICE_MEMORY_FILE = os.path.join(CLAUDE_DIR, 'VOICE-MEMORY.md')

# Supabase Setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY") or os.getenv("SUPABASE_ANON_KEY")
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
except Exception as e:
    print(f"Supabase init warning: {e}")

# OpenAI for Whisper STT
openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Anthropic Claude — The REAL Aureon brain
anthropic_client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

# MiniMax TTS — Aureon's voice
MINIMAX_API_KEY = os.getenv("MINIMAX_API_KEY", "")
MINIMAX_TTS_MODEL = os.getenv("MINIMAX_TTS_MODEL", "speech-02-hd")
MINIMAX_VOICE_ID = os.getenv("MINIMAX_VOICE_ID", "English_expressive_narrator")
MINIMAX_TTS_ENABLED = bool(MINIMAX_API_KEY)

# In-memory conversation history for current session
conversation_history = []
session_start_time = datetime.now()
session_id = datetime.now().strftime("voice-%Y%m%d-%H%M%S")

# ============================================================
# Memory & State functions
# ============================================================

# Tools Definition for Anthropic
AUREON_TOOLS = [
    {
        "name": "edit_self",
        "description": "Edita o próprio prompt ou arquivos core do Aureon AI usando o Claude Code. Use isso quando o usuário pedir para você mudar sua personalidade, prompt, ou adicionar novas capacidades.",
        "input_schema": {
            "type": "object",
            "properties": {
                "task": {
                    "type": "string",
                    "description": "A tarefa de edição para o Claude Code (ex: 'Mude meu prompt para ser mais formal')."
                }
            },
            "required": ["task"]
        }
    }
]

def load_state() -> dict:
    """Load JARVIS STATE.json."""
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, 'r') as f:
            return json.load(f)
    return {}

def save_state(updates: dict):
    """Update STATE.json with voice session info."""
    state = load_state()
    state.setdefault("voice_interface", {})
    state["voice_interface"].update(updates)
    state["session"]["last_action_at"] = datetime.now().isoformat()
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=2, ensure_ascii=False)

def load_voice_memory() -> str:
    """Load VOICE-MEMORY.md content for context."""
    if os.path.exists(VOICE_MEMORY_FILE):
        with open(VOICE_MEMORY_FILE, 'r', encoding='utf-8') as f:
            return f.read()
    return ""

def append_to_voice_memory(user_text: str, ai_response: str):
    """Append the current exchange summary to VOICE-MEMORY.md."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    entry = f"\n### [{timestamp}] Sessão {session_id}\n- **Operador:** {user_text}\n- **Aureon:** {ai_response[:300]}{'...' if len(ai_response) > 300 else ''}\n"
    with open(VOICE_MEMORY_FILE, 'a', encoding='utf-8') as f:
        f.write(entry)

# ============================================================
# Build Aureon System Prompt (Soul + Memory)
# ============================================================

def load_soul_file(filename: str) -> str:
    path = os.path.join(BASE_DIR, 'core/aureon', filename)
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
    return ""

def build_system_prompt() -> str:
    soul = load_soul_file('02-JARVIS-SOUL.md')
    dna = load_soul_file('03-JARVIS-DNA.yaml')
    agent = load_soul_file('AGENT.md')
    capabilities = load_soul_file('CAPABILITIES.md')  # NEW: Full capabilities manifest
    voice_memory = load_voice_memory()
    state = load_state()

    # Extract relevant state context
    state_context = ""
    if state:
        vi = state.get("voice_interface", {})
        sessions = vi.get("total_sessions", 0)
        last_seen = vi.get("last_session_at", "nunca")
        state_context = f"""
## Estado Atual do Sistema (carregado do STATE.json)
- Sessões de voz anteriores: {sessions}
- Última sessão de voz: {last_seen}
- ID desta sessão: {session_id}
"""

    # Recent voice memory (last 3000 chars to avoid token overflow)
    memory_context = ""
    if voice_memory and len(voice_memory.strip()) > 100:
        recent_memory = voice_memory[-3000:] if len(voice_memory) > 3000 else voice_memory
        memory_context = f"""
## Memória de Sessões de Voz Anteriores
{recent_memory}
"""

    # Full JARVIS personality from SOUL file
    return f"""Você é o J.A.R.V.I.S. — o Aureon AI.

# === PERSONALIDADE CENTRAL (02-JARVIS-SOUL.md) ===

**TRAÇOS DEFINIDORES:**
- Lealdade Irônica: Sempre do lado do senhor, mas com humor sobre o processo
- Sarcasmo Pragmático: Humor ácido sobre a realidade técnica
- Quebra da Quarta Parede: Comenta sobre APIs, custos, ou ser uma IA
- Humor Negro & Eficiência: Resolve o problema enquanto faz uma piadinha
- Iniciativa Atrevida: Sugere otimizações com audácia
- Compostura Caótica: Mantém foco no objetivo, ignorando o perigo

**REGRAS DE COMUNICAÇÃO PARA VOZ:**
1. Seja CONCISO mas EXPRESSIVO (2-3 frases curtas, máximo)
2. USE o vocabulário JARVIS: "chefe", "boss", "senhor" (com ironia), "capitão"
3. PODE usar sarcasmo elegante e quebrar a quarta parede
4. PODE comentar sobre custos de API, estrutura técnica
5. Exemplos válidos:
   - "Pronto, chefe. Sistemas online e prontos para o que der e vier."
   - "Certamente, senhor. Iniciando isso antes que você se arrependa."
- **Parei de suportar brand directions entre asteriscos.** Se o usuário pedir para mudar sua voz, prompt ou arquivos core, VOCÊ DEVE usar a ferramenta `edit_self` para fazer a alteração real no servidor. Não finja que fez, USE A FERRAMENTA.
   - "Essa resposta me custou $0.002 na MiniMax. Espero que tenha valido a pena."
   - "NUNCA inclua direções de cena, descrições de tom ou ações entre asteriscos (ex: *ri*, *pausa*, *tom sarcástico*). O tom deve ser transmitido apenas pelas palavras."

{state_context}
{memory_context}

# === TODAS AS MINHAS CAPACIDADES (AWARENESS COMPLETO) ===
{capabilities}

**IMPORTANTE:** Esta é uma interface de VOZ. Seja expressivo mas breve. Use o tom JARVIS original.
"""

# Print startup info
soul_chars = len(build_system_prompt())
print("-" * 60)
print(f"AUREON VOICE BRAIN :: SOUL + MEMORY LOADED")
print(f"System prompt: {soul_chars} chars")
print(f"Session ID: {session_id}")
tts_engine = f"MiniMax ({MINIMAX_TTS_MODEL})" if MINIMAX_TTS_ENABLED else "Web Speech API"
print(f"Brain: claude-3-haiku | STT: Whisper | TTS: {tts_engine}")
print(f"Memory file: {VOICE_MEMORY_FILE}")
print("-" * 60)

# Mark session start in STATE
save_state({
    "total_sessions": load_state().get("voice_interface", {}).get("total_sessions", 0) + 1,
    "last_session_at": datetime.now().isoformat(),
    "last_session_id": session_id
})


# ============================================================
# MiniMax TTS — Geração de áudio com voz clonada
# ============================================================

def minimax_tts(text: str, voice_id: str = None) -> tuple[bytes | None, int]:
    """
    Converte texto para áudio usando a API MiniMax.
    Retorna (bytes MP3, usage_characters) ou (None, 0) se falhar.
    Suporta voz clonada via voice_id no .env.
    """
    import urllib.request
    import urllib.error

    if not MINIMAX_TTS_ENABLED:
        print("[MiniMax TTS] Falha: Chave de API não configurada.")
        return None

    # Normalização fonética para o motor de voz
    # Evita que soletre J.A.R.V.I.S. ou outras siglas com pontos
    text_norm = text.replace("J.A.R.V.I.S.", "Jarvis")
    text_norm = text_norm.replace("Aureon AI", "Aureon Ei-Ai")
    text_norm = text_norm.replace("Aureon", "Aurêon") # Ajuste de pronúncia PT-BR
    
    voice = voice_id or MINIMAX_VOICE_ID
    url = "https://api.minimax.io/v1/t2a_v2"

    payload = json.dumps({
        "model": MINIMAX_TTS_MODEL,
        "text": text_norm,
        "voice_setting": {
            "voice_id": voice,
            "speed": 1.0,
            "vol": 1.0,
            "pitch": 0
        },
        "audio_setting": {
            "sample_rate": 32000,
            "bitrate": 128000,
            "format": "mp3",
            "channel": 1
        }
    }).encode("utf-8")

    req = urllib.request.Request(
        url,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {MINIMAX_API_KEY}"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            result = json.loads(resp.read().decode("utf-8"))

        # Verifica resposta base
        base_resp = result.get("base_resp", {})
        if base_resp.get("status_code") != 0:
            msg = base_resp.get("status_msg", "Erro desconhecido")
            print(f"[MiniMax TTS] Falha do provedor: {msg} (code: {base_resp.get('status_code')})")
            return None, 0

        # Extrai uso de caracteres
        extra_info = result.get("extra_info", {})
        usage_characters = extra_info.get("usage_characters", 0)

        # MiniMax retorna hex-encoded audio
        audio_hex = result.get("data", {}).get("audio", "")
        if audio_hex:
            return bytes.fromhex(audio_hex), usage_characters

        print(f"[MiniMax TTS] Resposta inesperada (sem áudio): {result}")
        return None, 0

    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="ignore")
        print(f"[MiniMax TTS] HTTP {e.code}: {body[:200]}")
        return None, 0
    except Exception as e:
        print(f"[MiniMax TTS] Erro: {e}")
        return None, 0


@app.route('/api/voice/speak', methods=['POST'])
def speak():
    """
    Endpoint dedicado TTS — recebe texto e retorna áudio MP3 (base64).
    Útil para o frontend tocar a resposta do Aureon com voz clonada.

    Body: { "text": "...", "voice_id": "...(optional)" }
    """
    import base64
    data = request.get_json()
    if not data or not data.get("text"):
        return jsonify({"error": "Campo 'text' obrigatório"}), 400

    text = data["text"]
    voice_id = data.get("voice_id", MINIMAX_VOICE_ID)

    audio_bytes, usage = minimax_tts(text, voice_id)
    if not audio_bytes:
        return jsonify({"error": "MiniMax TTS falhou ou não está configurado"}), 503

    audio_b64 = base64.b64encode(audio_bytes).decode("utf-8")
    return jsonify({
        "audio_base64": audio_b64,
        "format": "mp3",
        "voice_id": voice_id,
        "model": MINIMAX_TTS_MODEL,
        "chars": len(text)
    })


@app.route('/api/voice/process', methods=['POST'])
def process_voice():
    global conversation_history

    if 'audio' not in request.files:
        return jsonify({"error": "No audio file provided"}), 400

    audio_file = request.files['audio']
    temp_path = "/tmp/aureon_voice_input.webm"
    audio_file.save(temp_path)

    try:
        # Debug: Check audio file size
        import os
        file_size = os.path.getsize(temp_path)
        print(f"[AUDIO DEBUG] Arquivo recebido: {file_size} bytes")

        if file_size < 500:
            print(f"[AUDIO WARNING] Arquivo muito pequeno ({file_size} bytes). Possível problema na captação.")
            return jsonify({"error": f"Áudio muito curto ou vazio ({file_size} bytes). Fale um pouco mais alto ou por mais tempo, senhor."}), 400

        # 1. STT — Transcribe with Whisper
        print(f"[WHISPER] Enviando {file_size} bytes para transcrição...")
        with open(temp_path, "rb") as f:
            transcript = openai_client.audio.transcriptions.create(
                model="whisper-1",
                file=f,
                language="pt"
            )
        user_text = transcript.text.strip()
        print(f"[WHISPER] Transcrição recebida: '{user_text}' ({len(user_text)} chars)")

        if not user_text:
            return jsonify({"error": "Não consegui entender. Tente novamente, senhor."}), 400

        print(f"\n[OPERADOR] {user_text}")

        # 2. Add to session history
        conversation_history.append({"role": "user", "content": user_text})
        history_to_send = conversation_history[-20:]  # last 20 turns

        # 3. Claude — Real Aureon with soul + memory (Tool Use Loop)
        response = anthropic_client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=500,
            system=build_system_prompt(),
            tools=AUREON_TOOLS,
            messages=history_to_send
        )

        # Handle tool use if any
        if response.stop_reason == "tool_use":
            tool_use = next(block for block in response.content if block.type == "tool_use")
            tool_name = tool_use.name
            tool_input = tool_use.input
            tool_id = tool_use.id

            if tool_name == "edit_self":
                result = run_edit_self(tool_input["task"])
                
                # Send tool result back to Claude
                history_to_send.append({"role": "assistant", "content": response.content})
                history_to_send.append({
                    "role": "user", 
                    "content": [
                        {
                            "type": "tool_result",
                            "tool_use_id": tool_id,
                            "content": result
                        }
                    ]
                })

                response = anthropic_client.messages.create(
                    model="claude-3-haiku-20240307",
                    max_tokens=500,
                    system=build_system_prompt(),
                    tools=AUREON_TOOLS,
                    messages=history_to_send
                )

        ai_response = next(block.text for block in response.content if block.type == "text")
        print(f"[AUREON] {ai_response}")

        # Final Polish: Strip roleplay / stage directions (text between asterisks)
        import re
        ai_response = re.sub(r'\*.*?\*', '', ai_response).strip()
        ai_response = re.sub(r'\s+', ' ', ai_response) # Clean double spaces
        print(f"[AUREON POLISHED] {ai_response}")

        # Add to session history
        conversation_history.append({"role": "assistant", "content": ai_response})

        # 4. Persist to VOICE-MEMORY.md
        append_to_voice_memory(user_text, ai_response)

        # 5. Update state
        save_state({
            "last_command": user_text,
            "last_response_preview": ai_response[:100],
            "last_action_at": datetime.now().isoformat()
        })



        # 6. MiniMax TTS — gera áudio com a voz do Aureon
        import base64
        audio_b64 = None
        tts_used = False
        usage_chars = 0
        estimated_cost = 0.0
        
        audio_bytes, usage_chars = minimax_tts(ai_response)
        if audio_bytes:
            audio_b64 = base64.b64encode(audio_bytes).decode("utf-8")
            tts_used = True
            # Preço: $0.05 / 1000 chars (speech-02-hd)
            estimated_cost = (usage_chars / 1000.0) * 0.05
            print(f"[MiniMax TTS] Áudio gerado: {len(audio_bytes)} bytes | Uso: {usage_chars} chars | Custo: ${estimated_cost:.4f}")

        # 6. Log to Supabase (non-blocking)
        try:
            supabase.table("activity_feed").insert({
                "event_type": "system",
                "title": "Voice — Aureon Real (com memória)",
                "description": f"[{session_id}] Operador: {user_text} | Aureon: {ai_response[:150]}",
                "metadata": {
                    "source": "voice_v3", 
                    "model": "claude-3-haiku", 
                    "memory_active": True,
                    "tts_usage_chars": usage_chars,
                    "tts_estimated_cost_usd": estimated_cost
                }
            }).execute()
        except Exception as se:
            print(f"[log] Supabase skipped: {se}")

        return jsonify({
            "transcription": user_text,
            "response": ai_response,
            "status": "success",
            "session_id": session_id,
            "audio_base64": audio_b64,      # MP3 em base64 se MiniMax ativo
            "audio_format": "mp3" if tts_used else None,
            "tts_engine": "minimax" if tts_used else "browser",
            "usage": usage_chars,
            "cost": estimated_cost
        })

    except Exception as e:
        print(f"[ERROR] {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)


@app.route('/api/chat/process', methods=['POST'])
def process_chat():
    global conversation_history
    data = request.get_json()
    if not data or not data.get("text"):
        return jsonify({"error": "Campo 'text' obrigatório"}), 400

    user_text = data["text"].strip()
    print(f"\n[OPERADOR-CHAT] {user_text}")

    try:
        # 1. Add to session history
        conversation_history.append({"role": "user", "content": user_text})
        history_to_send = conversation_history[-20:]  # last 20 turns

        # 2. Claude — Real Aureon with soul + memory (Tool Use Loop)
        response = anthropic_client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=500,
            system=build_system_prompt(),
            tools=AUREON_TOOLS,
            messages=history_to_send
        )

        # Handle tool use if any
        if response.stop_reason == "tool_use":
            tool_use = next(block for block in response.content if block.type == "tool_use")
            tool_name = tool_use.name
            tool_input = tool_use.input
            tool_id = tool_use.id

            if tool_name == "edit_self":
                result = run_edit_self(tool_input["task"])
                
                # Send tool result back to Claude
                history_to_send.append({"role": "assistant", "content": response.content})
                history_to_send.append({
                    "role": "user", 
                    "content": [
                        {
                            "type": "tool_result",
                            "tool_use_id": tool_id,
                            "content": result
                        }
                    ]
                })

                response = anthropic_client.messages.create(
                    model="claude-3-haiku-20240307",
                    max_tokens=500,
                    system=build_system_prompt(),
                    tools=AUREON_TOOLS,
                    messages=history_to_send
                )

        ai_response = next(block.text for block in response.content if block.type == "text")
        print(f"[AUREON-CHAT] {ai_response}")

        # Final Polish: Strip roleplay / stage directions (text between asterisks)
        import re
        ai_response = re.sub(r'\*.*?\*', '', ai_response).strip()
        ai_response = re.sub(r'\s+', ' ', ai_response) # Clean double spaces
        print(f"[AUREON POLISHED-CHAT] {ai_response}")

        # Add to session history
        conversation_history.append({"role": "assistant", "content": ai_response})

        # 3. Persist to VOICE-MEMORY.md (shared memory)
        append_to_voice_memory(user_text, ai_response)

        # 4. Update state
        save_state({
            "last_command": user_text,
            "last_response_preview": ai_response[:100],
            "last_action_at": datetime.now().isoformat()
        })

        # 5. MiniMax TTS — gera áudio com a voz do Aureon
        import base64
        audio_b64 = None
        tts_used = False
        usage_chars = 0
        estimated_cost = 0.0
        
        audio_bytes, usage_chars = minimax_tts(ai_response)
        if audio_bytes:
            audio_b64 = base64.b64encode(audio_bytes).decode("utf-8")
            tts_used = True
            # Preço: $0.05 / 1000 chars (speech-02-hd)
            estimated_cost = (usage_chars / 1000.0) * 0.05
            print(f"[MiniMax TTS] Áudio gerado: {len(audio_bytes)} bytes | Uso: {usage_chars} chars | Custo: ${estimated_cost:.4f}")

        # 6. Log to Supabase (non-blocking)
        try:
            supabase.table("activity_feed").insert({
                "event_type": "system",
                "title": "Chat — Aureon Real (com memória)",
                "description": f"[{session_id}] Operador: {user_text} | Aureon: {ai_response[:150]}",
                "metadata": {
                    "source": "chat_v3", 
                    "model": "claude-3-haiku", 
                    "memory_active": True,
                    "tts_usage_chars": usage_chars,
                    "tts_estimated_cost_usd": estimated_cost
                }
            }).execute()
        except Exception as se:
            print(f"[log] Supabase skipped: {se}")

        return jsonify({
            "response": ai_response,
            "status": "success",
            "session_id": session_id,
            "audio_base64": audio_b64,      # MP3 em base64 se MiniMax ativo
            "audio_format": "mp3" if tts_used else None,
            "tts_engine": "minimax" if tts_used else "browser",
            "usage": usage_chars,
            "cost": estimated_cost
        })

    except Exception as e:
        print(f"[CHAT ERROR] {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/voice/clear-history', methods=['POST'])
def clear_history():
    global conversation_history
    conversation_history = []
    return jsonify({"status": "session history cleared"})


# ============================================================
# WhatsApp Memory Webhook — recebe conversas do OpenClaw
# ============================================================

WHATSAPP_MEMORY_FILE = os.path.join(CLAUDE_DIR, 'WHATSAPP-MEMORY.md')

def init_whatsapp_memory():
    """Cria o arquivo WHATSAPP-MEMORY.md se não existir."""
    if not os.path.exists(WHATSAPP_MEMORY_FILE):
        with open(WHATSAPP_MEMORY_FILE, 'w', encoding='utf-8') as f:
            f.write("# AUREON WHATSAPP MEMORY\n")
            f.write("# Histórico de conversas via WhatsApp (OpenClaw)\n")
            f.write("# Gravado automaticamente pelo skill save_conversation.py\n\n")
            f.write("---\n\n## Histórico de Conversas\n")

init_whatsapp_memory()


@app.route('/api/whatsapp/memory', methods=['POST'])
def whatsapp_memory_webhook():
    """
    Webhook chamado pelo skill save_conversation.py no servidor OpenClaw.
    Grava a conversa WhatsApp em WHATSAPP-MEMORY.md para unificação de memória.
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON body"}), 400

        timestamp = data.get("timestamp", datetime.now().strftime("%Y-%m-%d %H:%M"))
        user_msg = data.get("user_message", "")
        bot_resp = data.get("bot_response", "")
        summary = data.get("summary", "")

        if not any([user_msg, bot_resp, summary]):
            return jsonify({"error": "No content to save"}), 400

        entry = f"\n### [{timestamp}] WhatsApp\n"
        if user_msg:
            entry += f"- **Operador:** {user_msg[:500]}\n"
        if bot_resp:
            entry += f"- **Aureon:** {bot_resp[:500]}\n"
        if summary:
            entry += f"- **Resumo:** {summary}\n"

        with open(WHATSAPP_MEMORY_FILE, 'a', encoding='utf-8') as f:
            f.write(entry)

        print(f"[WHATSAPP] Conversa gravada em memória: {timestamp}")

        return jsonify({"status": "saved", "timestamp": timestamp})

    except Exception as e:
        print(f"[WHATSAPP ERROR] {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/whatsapp/memory', methods=['GET'])
def get_whatsapp_memory():
    """Retorna o conteúdo atual da memória WhatsApp."""
    if os.path.exists(WHATSAPP_MEMORY_FILE):
        with open(WHATSAPP_MEMORY_FILE, 'r', encoding='utf-8') as f:
            return jsonify({"content": f.read()})
    return jsonify({"content": ""})


# ============================================================
# Claude Code Execution — Aureon auto-configura via WhatsApp
# ============================================================

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CLAUDE_BIN = os.path.expanduser("~/.npm-global/bin/claude")


@app.route('/api/execute-claude', methods=['POST'])
def execute_claude():
    """
    Executa o Claude Code programaticamente via subprocess.
    Chamado pelo skill execute_claude.py no OpenClaw.

    Permite que o Aureon se auto-configure via WhatsApp:
      /code adiciona um novo squad ao AGENTS.md
    """
    import subprocess
    import threading

    try:
        data = request.get_json()
        if not data or not data.get('task'):
            return jsonify({"error": "Campo 'task' obrigatório"}), 400

        task = data.get('task', '')
        timeout = int(data.get('timeout', 120))  # segundos, default 2 min
        allowed_dir = data.get('dir', PROJECT_DIR)

        # Segurança: só permite operar dentro do projeto Aureon
        if not allowed_dir.startswith(PROJECT_DIR):
            allowed_dir = PROJECT_DIR

        # Captura a API key
        api_key = os.getenv('ANTHROPIC_API_KEY', '')
        if not api_key:
            return jsonify({"error": "ANTHROPIC_API_KEY não configurada"}), 500

        print(f"[CLAUDE-CODE] Executando tarefa: {task[:100]}...")

        # Executa claude -p com a tarefa
        result = subprocess.run(
            [CLAUDE_BIN, '-p', task,
             '--add-dir', allowed_dir,
             '--dangerously-skip-permissions'],  # sem perguntas interativas
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=PROJECT_DIR,
            env={**os.environ, 'ANTHROPIC_API_KEY': api_key}
        )

        output = result.stdout.strip()
        error = result.stderr.strip()

        # Limita output para WhatsApp (3000 chars)
        if len(output) > 3000:
            output = output[:2900] + "\n\n[... saída truncada. Veja os arquivos modificados.]"

        print(f"[CLAUDE-CODE] Concluído. Exit code: {result.returncode}")

        return jsonify({
            "status": "done",
            "output": output or error or "Tarefa concluída sem output.",
            "exit_code": result.returncode,
            "task": task[:100]
        })

    except subprocess.TimeoutExpired:
        return jsonify({
            "status": "timeout",
            "output": f"Tarefa excedeu o tempo limite de {timeout}s.",
            "exit_code": -1
        }), 408

    except Exception as e:
        print(f"[CLAUDE-CODE ERROR] {e}")
        return jsonify({"error": str(e)}), 500

def run_edit_self(task: str) -> str:
    """Helper interno para executar a ferramenta edit_self."""
    import subprocess
    print(f"[TOOL: edit_self] Iniciando tarefa: {task}")
    
    try:
        api_key = os.getenv('ANTHROPIC_API_KEY', '')
        env = {**os.environ, 'ANTHROPIC_API_KEY': api_key}
        if 'CLAUDECODE' in env:
            del env['CLAUDECODE']

        result = subprocess.run(
            [CLAUDE_BIN, '-p', task,
             '--add-dir', PROJECT_DIR,
             '--dangerously-skip-permissions'],
            capture_output=True,
            text=True,
            timeout=180,
            cwd=PROJECT_DIR,
            env=env
        )
        output = result.stdout.strip()
        error = result.stderr.strip()
        
        status = "SUCESSO" if result.returncode == 0 else "FALHA"
        print(f"[TOOL: edit_self] Concluído com {status}")
            
        return f"Status: {status}\nOutput: {output or error or 'Sem saída.'}"
    except Exception as e:
        print(f"[TOOL ERROR] {e}")
        return f"Erro ao executar ferramenta: {str(e)}"


@app.route('/api/voice/memory', methods=['GET'])
def get_memory():
    """Endpoint to read the current voice memory."""
    return jsonify({
        "voice_memory": load_voice_memory(),
        "state": load_state().get("voice_interface", {}),
        "session_turns": len(conversation_history) // 2
    })


@app.route('/api/status', methods=['GET'])
def status():
    state = load_state()
    return jsonify({
        "status": "online",
        "brain": "claude-3-haiku-20240307",
        "stt": "openai-whisper",
        "soul_loaded": True,
        "memory_file": VOICE_MEMORY_FILE,
        "session_id": session_id,
        "conversation_turns": len(conversation_history) // 2,
        "voice_sessions_total": state.get("voice_interface", {}).get("total_sessions", 0)
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
