precision highp float;
uniform sampler2D samplerTexture;
varying vec2 varyTextureCoord;
void main(){
    vec4 mask = texture2D(samplerTexture,varyTextureCoord);
    gl_FragColor = mask;
}
