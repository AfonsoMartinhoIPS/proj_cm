#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
/* STREAMING_CHUNK: Normalizando as coordenadas do ecrã... */
vec2 uv = FlutterFragCoord().xy / uSize;

// Cores reais do teu projeto (convertidas para float 0.0 - 1.0)
// AppColors.background (0xFF344E41)
vec3 bgColor = vec3(0.203, 0.305, 0.254); 
// AppColors.primary (0xFF588157)
vec3 waveColor = vec3(0.345, 0.505, 0.341); 

/* STREAMING_CHUNK: Calculando as alturas das ondas com offsets reduzidos para as subir... */
// Reduzimos o offset de ~0.5 para ~0.35 para mover a linha de transição para o topo do ecrã
// Onda 1: Movimento mais largo e lento
float wave1 = sin(uv.x * 4.0 + uTime * 1.5) * 0.05 + 0.35;

// Onda 2: Movimento mais rápido e curto para dar complexidade orgânica
float wave2 = sin(uv.x * 8.0 - uTime * 2.2) * 0.03 + 0.33;

// Combinar as duas ondas
float finalWaveHeight = mix(wave1, wave2, 0.5);

/* STREAMING_CHUNK: Criando a transição suave e misturando as cores... */
// Criar uma linha de transição suave (antialiasing) na borda da onda
float edge = smoothstep(finalWaveHeight, finalWaveHeight + 0.005, uv.y);

// Mistura o fundo com a onda
vec3 finalColor = mix(waveColor, bgColor, edge);

fragColor = vec4(finalColor, 1.0);


}