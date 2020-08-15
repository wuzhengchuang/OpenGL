precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
void main(void){
    vec2 uv = varyTextCoord.xy;
    float y;
    if (uv.y>=0.0&&uv.y<0.3333) {
        y=uv.y+0.3333;
    }else if (uv.y>=0.3333&&uv.y<0.6666){
        y=uv.y;
    }else{
        y=uv.y-0.3333;
    }
    gl_FragColor = texture2D(colorMap,vec2(uv.x,y));
}
