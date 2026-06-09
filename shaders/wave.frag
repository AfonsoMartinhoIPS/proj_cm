#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uBgColor;
uniform vec3 uWaveColor;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    float wave1 = sin(uv.x * 4.0 + uTime * 1.5) * 0.05 + 0.35;
    float wave2 = sin(uv.x * 8.0 - uTime * 2.2) * 0.03 + 0.33;
    float finalWaveHeight = mix(wave1, wave2, 0.5);
    float edge = smoothstep(finalWaveHeight, finalWaveHeight + 0.005, uv.y);
    vec3 finalColor = mix(uWaveColor, uBgColor, edge);
    fragColor = vec4(finalColor, 1.0);
}