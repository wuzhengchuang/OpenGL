precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextureCoord;
void main(void){
    gl_FragColor = texture2D(colorMap,varyTextureCoord);
}
