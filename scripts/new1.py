import os
import subprocess
import speech_recognition as sr
import pyttsx3
import requests
import time

API_KEY = "REDACTED_ASSIGNED_SECRET"

# Categorized Models (Verified Free Models first)
# 'openrouter/auto' with ':free' suffix or 'openrouter/free' can also be used as a catch-all
FREE_MODELS = [
    "meta-llama/llama-3.3-70b-instruct:free",
    "qwen/qwen3-next-80b-a3b-instruct:free",
    "meta-llama/llama-3.2-3b-instruct:free",
    "liquid/lfm-2.5-1.2b-instruct:free",
    "nvidia/nemotron-3-nano-30b-a3b:free",
    "google/gemma-4-31b-it:free",
    "openrouter/free" # Catch-all free model
]

PAID_MODELS = {
    "gemini": "google/gemini-2.0-flash-001",
    "claude": "anthropic/claude-3.5-sonnet",
    "gpt": "openai/gpt-4o-mini"
}

# All accessible models for manual switching
ALL_MODELS = {
    "llama": "meta-llama/llama-3.3-70b-instruct:free",
    "qwen": "qwen/qwen3-next-80b-a3b-instruct:free",
    "liquid": "liquid/lfm-2.5-1.2b-instruct:free",
    "gemini": "google/gemini-2.0-flash-001",
    "claude": "anthropic/claude-3.5-sonnet",
    "gpt": "openai/gpt-4o-mini",
    "auto": "openrouter/free"
}

CURRENT_MODEL = FREE_MODELS[0]

class CustomTTS:
    def __init__(self):
        self.rate = 145
        try:
            if os.system("aplay --version > /dev/null 2>&1") != 0:
                print("[INFO] 'aplay' not found. Using espeak-ng for audio output.")
                self.engine = None
            else:
                self.engine = pyttsx3.init()
        except Exception as e:
            self.engine = None
            print(f"[INFO] pyttsx3 initialization failed ({e}). Using espeak-ng fallback.")

    def setProperty(self, prop, val):
        if self.engine:
            try: self.engine.setProperty(prop, val)
            except: pass
        if prop == 'rate': self.rate = val

    def getProperty(self, prop):
        if self.engine:
            try: return self.engine.getProperty(prop)
            except: pass
        return []

    def say(self, text):
        if self.engine:
            self.engine.say(text)
        else:
            subprocess.run(["espeak-ng", "-s", str(self.rate), text], stderr=subprocess.DEVNULL)

    def runAndWait(self):
        if self.engine:
            try:
                self.engine.runAndWait()
            except Exception as e:
                print(f"[ERROR] pyttsx3 runAndWait failed: {e}. Switching to espeak-ng.")
                self.engine = None

tts = CustomTTS()
tts.setProperty('rate', 145)

def speak(text):
    print(f"JARVIS: {text}")
    tts.say(text)
    tts.runAndWait()

def listen():
    r = sr.Recognizer()
    r.energy_threshold = 300
    r.dynamic_energy_threshold = True
    r.dynamic_energy_adjustment_damping = 0.15
    r.pause_threshold = 1.2
    
    with sr.Microphone() as source:
        model_name = CURRENT_MODEL.split('/')[-1]
        print(f"\n[LISTENING - Model: {model_name}]")
        try:
            audio = r.listen(source, timeout=5, phrase_time_limit=15)
            print("[PROCESSING]")
            query = r.recognize_google(audio)
            print(f"YOU: {query}")
            return query
        except Exception:
            return None

def query_llm(prompt):
    global CURRENT_MODEL
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:3000",
        "X-Title": "JarvisLite"
    }
    
    # Try the current model first, then fallback to other free models
    models_to_try = [CURRENT_MODEL]
    if CURRENT_MODEL in FREE_MODELS:
        # Add all other free models to the try list
        models_to_try.extend([m for m in FREE_MODELS if m != CURRENT_MODEL])
    
    for i, model in enumerate(models_to_try):
        data = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 150
        }
        try:
            res = requests.post("https://openrouter.ai/api/v1/chat/completions", headers=headers, json=data, timeout=10)
            if res.status_code == 200:
                if model != CURRENT_MODEL:
                    print(f"[INFO] Used fallback: {model}")
                return res.json()['choices'][0]['message']['content']
            
            # If 402, user is out of credits and tried a paid model
            if res.status_code == 402:
                if model in FREE_MODELS:
                    continue 
                return "API Error: Insufficient credits. Please switch to a 'free' model."
            
            # If 429, 404, or 5xx, try the next model
            if res.status_code in [404, 429, 500, 502, 503, 504]:
                print(f"[WARN] Model {model} failed with {res.status_code}. Trying next...")
                # Add a tiny delay between retries to avoid hammering
                if i < len(models_to_try) - 1:
                    time.sleep(0.5)
                continue
            
            # For other errors, just return the error
            try:
                err_msg = res.json().get('error', {}).get('message', res.text)
            except:
                err_msg = res.text
            return f"API Error Code {res.status_code}: {err_msg}"
            
        except Exception as e:
            print(f"[ERROR] Connection error with {model}: {e}")
            continue

    return "All available models failed to respond. Please check your internet connection or try again later."

if __name__ == "__main__":
    speak("System online. Robust fallback enabled.")
    while True:
        text = listen()
        if text:
            text_lower = text.lower()
            if any(w in text_lower for w in ["exit", "quit", "terminate"]):
                speak("Shutting down systems.")
                break
            
            # Model list logic
            if "list models" in text_lower or "what models" in text_lower:
                model_names = ", ".join(ALL_MODELS.keys())
                speak(f"Available models are: {model_names}. Currently using {CURRENT_MODEL.split('/')[-1]}.")
                continue

            # Model switching logic
            switched = False
            for name, model_id in ALL_MODELS.items():
                if f"switch to {name}" in text_lower or f"use {name}" in text_lower:
                    CURRENT_MODEL = model_id
                    speak(f"Switching to {name} model.")
                    switched = True
                    break
            
            if switched:
                continue

            reply = query_llm(text)
            speak(reply)
