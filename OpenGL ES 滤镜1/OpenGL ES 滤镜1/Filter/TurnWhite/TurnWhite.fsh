precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextureCoord;
uniform float time;
const float duration = 0.7;
const float PI = 3.1415926;
void main(void){
    float Time = mod(time,duration);
    float amplitude = abs(sin(time*(PI/duration)));
    vec4 whiteMask = vec4(1.0,1.0,1.0,1.0);
    vec4 mask = texture2D(colorMap,varyTextureCoord);
//    float R =  mask.r+(1.0-mask.r)*amplitude;
//    float G =  mask.g+(1.0-mask.g)*amplitude;
//    float B =  mask.b+(1.0-mask.b)*amplitude;
//    float A =  mask.a+(1.0-mask.a)*amplitude;
    gl_FragColor = mix(mask,whiteMask,amplitude);
}
