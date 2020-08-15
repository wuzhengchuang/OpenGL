precision highp float;
uniform sampler2D colorMap;
varying vec2 varyTextureCoord;
void main(void){
    vec2 uv = varyTextureCoord;
    float x=uv.x,y=uv.y;
    if (uv.x>=0.0&&uv.x<0.5) {
        x=uv.x*2.0;
    }else{
        x=(uv.x-0.5)*2.0;
    }
    if (uv.y>=0.0&&uv.y<0.5) {
        y=uv.y*2.0;
    }else{
        y=(uv.y-0.5)*2.0;
    }
    gl_FragColor = texture2D(colorMap,vec2(x,y));
}
