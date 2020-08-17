precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
void main(void){
    vec4 mask = texture2D(colorMap,vec2(varyTextCoord.x,1.0-varyTextCoord.y));
    gl_FragColor = vec4(mask);
}
