precision highp float;
varying lowp vec4 varyColor;
varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;
uniform lowp float alpha;
void main(){
    vec4 weakMask = texture2D(colorMap,varyTextCoord);
    vec4 mask = varyColor;
    vec4 tempColor = mask * (1.0-alpha) + weakMask * alpha;
    gl_FragColor = tempColor;
}
