precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
const highp vec3 W = vec3(0.2125,0.7154,0.0721);
void main(void){
    vec4 mask = texture2D(colorMap,varyTextCoord);
    float luminance = dot(mask.rgb,W);//点乘，向量相乘
    gl_FragColor = vec4(vec3(luminance),1.0);
}
