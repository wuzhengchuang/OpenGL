precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
uniform float time;
void main(void){
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;
    
    float progress = mod(time,duration)/duration;
    
    vec2 offsetCoords = vec2(offset,offset)*progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
//    float weakX = 0.5 + (varyTextCoord.x-0.5)/scale;
//    float weakY = 0.5 + (varyTextCoord.y-0.5)/scale;
//    vec2 weakCoord = vec2(weakX,weakY);
    vec2 weakCoord = vec2(0.5,0.5)+(varyTextCoord-vec2(0.5,0.5))/scale;
    vec4 weakMask = texture2D(colorMap,weakCoord+offsetCoords);
    vec4 maskR = texture2D(colorMap,weakCoord+offsetCoords);
    vec4 maskB = texture2D(colorMap,weakCoord-offsetCoords);
    vec4 mask = texture2D(colorMap,weakCoord);
    
    gl_FragColor = vec4(maskR.r,mask.g,maskB.b,mask.a);
}
