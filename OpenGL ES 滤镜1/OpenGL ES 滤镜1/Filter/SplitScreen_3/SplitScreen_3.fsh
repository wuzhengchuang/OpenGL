precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextCoord;
void main(void){
    vec2 uv = varyTextCoord.xy;
    float y;
    if (uv.y>=0.0&&uv.y<1.0/3.0) {
        y=uv.y+1.0/3.0;
    }else if (uv.y>=1.0/3.0&&uv.y<2.0/3.0){
        y=uv.y;
    }else{
        y=uv.y-1.0/3.0;
    }
    gl_FragColor = texture2D(colorMap,vec2(uv.x,y));
}
