from flask import Flask, request, jsonify
from flask_cors import CORS
from google import genai
import os
import json
import re
import time
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

TEMAS_POR_NIVEL = {
    1: "variables en Python (int, str, float, bool, asignación)",
    2: "condicionales en Python (if, elif, else)",
    3: "bucles en Python (for, while, range)",
    4: "funciones en Python (def, return, parámetros)",
    5: "listas en Python (indexing, append, len, slicing)",
    6: "diccionarios en Python (keys, values, get, items)",
    7: "clases en Python (class, __init__, self, métodos)",
    8: "módulos en Python (import, from, as, pip)",
}

@app.route("/generar-pregunta", methods=["POST"])
def generar_pregunta():
    data = request.get_json()
    nivel = data.get("nivel", 1)
    tema = TEMAS_POR_NIVEL.get(nivel, "variables en Python")

    prompt = f"""Responde SIEMPRE en español. Genera una pregunta de opción múltiple en español sobre {tema}.
La pregunta debe ser clara y tener exactamente 4 opciones (A, B, C, D).
Solo una opción es correcta.
IMPORTANTE: Si incluyes código Python en la pregunta, escríbelo directamente en el texto usando saltos de línea normales. NO uses bloques de código markdown ni triple backtick.
Los nombres de variables en el código pueden estar en español o inglés pero las explicaciones SIEMPRE en español.

Responde ÚNICAMENTE con este JSON exacto, sin texto adicional, sin markdown:
{{
  "pregunta": "texto de la pregunta aquí en español",
  "opciones": ["A) opción 1", "B) opción 2", "C) opción 3", "D) opción 4"],
  "respuesta_correcta": "A",
  "explicacion": "explicación breve en español de por qué es correcta"
}}"""

    modelos = ["gemini-2.0-flash-lite", "gemini-2.0-flash", "gemini-2.5-flash"]

    for modelo in modelos:
        try:
            response = client.models.generate_content(
                model=modelo, contents=prompt
            )
            texto = response.text.strip()
            texto = re.sub(r"```json|```", "", texto).strip()
            pregunta_data = json.loads(texto)

            pregunta_texto = pregunta_data.get("pregunta", "")
            pregunta_texto = re.sub(r"```python\n?", "\n", pregunta_texto)
            pregunta_texto = re.sub(r"```\n?", "\n", pregunta_texto)
            pregunta_data["pregunta"] = pregunta_texto.strip()

            print(f"✅ Pregunta generada con {modelo}")
            return jsonify(pregunta_data), 200
        except Exception as e:
            error_str = str(e)
            print(f"❌ {modelo} falló: {error_str[:80]}")
            if "503" in error_str:
                time.sleep(2)
            continue

    return jsonify({"error": "Servicio de IA no disponible temporalmente"}), 500


@app.route("/validar-respuesta", methods=["POST"])
def validar_respuesta():
    data = request.get_json()
    opcion_seleccionada = data.get("opcion_seleccionada", "")
    respuesta_correcta = data.get("respuesta_correcta", "")
    explicacion = data.get("explicacion", "")

    correcto = opcion_seleccionada.strip().upper() == respuesta_correcta.strip().upper()

    if correcto:
        retroalimentacion = f"¡Correcto! {explicacion}"
    else:
        retroalimentacion = f"Incorrecto. La respuesta correcta era {respuesta_correcta}. {explicacion}"

    return jsonify({
        "correcto": correcto,
        "retroalimentacion": retroalimentacion
    }), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "mensaje": "Mortal Code API corriendo"}), 200


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)