precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextureCoord;
uniform float time;
const float duration = 0.3;
const float PI = 3.1415926;
float rand(float n){
    return fract(sin(n)*43758.5453123);
}
void main(void){
    float maxJitter = 0.06;
    float colorROffset = 0.01;
    float colorBOffset = -0.025;
    
    float Time = mod(time,duration*2.0);
    float amplitude = max(sin(time*(PI/duration)),0.0);
    float jitter = rand(varyTextureCoord.y)*2.0-1.0;
    
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    float textureX = varyTextureCoord.x + (needOffset ? jitter : (jitter * amplitude *0.006));
    vec2 textureCoord = vec2(textureX,varyTextureCoord.y);
    
    vec4 mask = texture2D(colorMap,textureCoord);
    
    vec4 maskR = texture2D(colorMap,textureCoord+vec2(colorROffset * amplitude,0.0));
    vec4 maskB = texture2D(colorMap,textureCoord+vec2(colorBOffset * amplitude,0.0));
    gl_FragColor = vec4(maskR.r,mask.g,maskB.b,mask.a);
}

