precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
uniform float time;
const float PI = 3.1415926;
const float duration = 0.7;
const float maxScale = 1.8;
const float maxAlpa = 0.4;
void main(void){
    float progress = mod(time,duration)/duration;
    float alpha = maxAlpa * (1.0 - progress);
    float scale = 1.0+(maxScale - 1.0)*progress;

    float weakX = 0.5+(varyTextCoord.x-0.5)/scale;
    float weakY = 0.5+(varyTextCoord.y-0.5)/scale;
    
    vec2 weakTextCoord = vec2(weakX,weakY);
    
    vec4 weakMask = texture2D(colorMap,weakTextCoord);
    vec4 mask = texture2D(colorMap,varyTextCoord);
    //mix => x(1-a) +y*a
    vec4 color = mix(mask,weakMask,alpha);
    gl_FragColor = color;
}

