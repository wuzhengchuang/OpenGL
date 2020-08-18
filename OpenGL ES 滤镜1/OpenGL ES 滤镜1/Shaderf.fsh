precision highp float;
uniform sampler2D bgTexture;
uniform sampler2D biankuangTexture;
varying vec2 varyTextCoord;
void main()
{
    vec4 bgMask = texture2D(bgTexture,varyTextCoord);
    vec4 bkMask = texture2D(biankuangTexture,varyTextCoord);
    gl_FragColor = mix(bgMask,bkMask,bkMask.a-0.1);
}
