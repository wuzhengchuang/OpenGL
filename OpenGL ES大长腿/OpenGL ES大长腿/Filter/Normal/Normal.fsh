precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextureCoord;
void main(void){
    vec4 mask = texture2D(colorMap,varyTextureCoord);
    gl_FragColor = mask;
}
