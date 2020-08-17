attribute vec4 position;
attribute vec2 textCoord;
varying vec2 varyTextCoord;
uniform float time;
const float PI = 3.1415926;
void main(void){
    varyTextCoord = textCoord;
    float duration = 0.6;
    float maxAmplitude = 0.3;
    float progress = mod(time,duration);
    float x = position.x;
    float y = position.y;
    float scale =1.0 + maxAmplitude*abs(sin(progress*(PI/duration)));
    gl_Position = vec4(x*scale,y*scale,position.zw);
}
