attribute vec4 position;
attribute vec2 textCoord;
varying lowp vec2 varyTextCoord;
void main(){
    varyTextCoord=textCoord;
    vec4 vPos=position;
    gl_Position=vPos;
}
