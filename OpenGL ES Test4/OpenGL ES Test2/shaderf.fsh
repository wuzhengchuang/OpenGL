precision highp float;
varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;
void main(){
    lowp vec4 temp = texture2D(colorMap,varyTextCoord);
    //图片翻转
//    lowp vec4 temp = texture2D(colorMap,vec2(varyTextCoord.x,1.0-varyTextCoord.y));
    gl_FragColor = temp;
}
